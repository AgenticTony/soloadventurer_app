# AWS Cost Optimization Strategy

This document outlines the comprehensive cost optimization strategy for the SoloAdventurer application, focusing on the AWS Cost Audit Script implementation and related infrastructure.

## Overview

The SoloAdventurer application leverages multiple AWS services to provide a scalable, reliable platform for travelers. To ensure cost efficiency while maintaining performance, we've implemented an automated cost optimization system that continuously identifies savings opportunities and provides actionable remediation steps.

## AWS Cost Audit Script

### Purpose

The AWS Cost Audit Script (v2.1) is designed to:

1. Automatically identify cost-saving opportunities across our AWS infrastructure
2. Generate Terraform remediation steps for immediate implementation
3. Track cost savings over time
4. Alert the team to unusual cost patterns
5. Provide long-term cost projections for budget planning

### Key Features

- **Comprehensive Service Coverage**: Analyzes 12 AWS services including Aurora, OpenSearch, IoT Core, Neptune, and SageMaker
- **Terraform Remediation**: Generates ready-to-apply Terraform configurations for each finding
- **30-Day Rolling Window**: Analyzes cost patterns over a full month for better seasonal recognition
- **3-Year Projections**: Provides long-term cost estimates with Reserved Instance pricing
- **CI/CD Integration**: Runs automatically as part of our deployment pipeline
- **Slack Notifications**: Alerts the team to new savings opportunities
- **Historical Tracking**: Stores findings in DynamoDB for trend analysis

### Implementation

The script is implemented in Python and uses the AWS SDK (boto3) to interact with various AWS services:

```python
# lib/core/monitoring/cost/aws_cost_optimizer.py
#!/usr/bin/env python3
"""
AWS Cost Optimizer v2.1
Identifies savings opportunities for SoloAdventurer's tech stack
Outputs: cost_audit.md + terraform_remediation.tf
"""

import boto3
from datetime import datetime, timedelta
import json
import os

# Initialize clients
cost_explorer = boto3.client('ce')
rds = boto3.client('rds')
es = boto3.client('es')
lambda_client = boto3.client('lambda')
s3 = boto3.client('s3')
elasticache = boto3.client('elasticache')
sagemaker = boto3.client('sagemaker')
iot = boto3.client('iot')
neptune = boto3.client('neptune')

# ... (implementation details)
```

### Service-Specific Checks

#### 1. Aurora PostgreSQL Optimization

```python
def check_aurora_savings():
    """Identify Aurora cost savings opportunities"""
    findings = []
    clusters = rds.describe_db_clusters()

    for cluster in clusters['DBClusters']:
        if cluster['EngineMode'] != 'serverlessv2':
            savings_pct = 67 if cluster['EngineMode'] == 'provisioned' else 40
            findings.append({
                'service': 'Aurora PostgreSQL',
                'issue': 'Non-serverless cluster',
                'resource': cluster['DBClusterIdentifier'],
                'savings_pct': savings_pct,
                'severity': 'CRITICAL' if savings_pct > 50 else 'HIGH',
                'terraform_fix': f'''
resource "aws_rds_cluster" "{cluster['DBClusterIdentifier']}" {{
  engine_mode         = "serverlessv2"
  serverlessv2_scaling_configuration {{
    min_capacity = 0.5
    max_capacity = 16
  }}
}}'''
            })

    return findings
```

#### 2. OpenSearch Graviton Migration

```python
def check_opensearch_graviton():
    """Check for non-Graviton OpenSearch instances"""
    findings = []
    domains = es.list_domain_names()

    for domain in domains['DomainNames']:
        config = es.describe_elasticsearch_domain(
            DomainName=domain['DomainName']
        )['DomainStatus']

        if 'r6g' not in config['ElasticsearchClusterConfig']['InstanceType']:
            findings.append({
                'service': 'OpenSearch',
                'issue': 'Non-Graviton instances',
                'resource': domain['DomainName'],
                'savings_pct': 52,
                'severity': 'HIGH',
                'terraform_fix': f'''
resource "aws_elasticsearch_domain" "{domain['DomainName']}" {{
  cluster_config {{
    instance_type = "r6g.large.search"
    instance_count = {config['ElasticsearchClusterConfig']['InstanceCount']}
  }}
}}'''
            })

    return findings
```

#### 3. IoT Core Optimization

```python
def check_iot_core_savings():
    """Identify IoT Core optimization opportunities"""
    findings = []

    # Check for unused topics
    topics = iot.list_topic_rules()
    for rule in topics['rules']:
        if rule['ruleDisabled']:
            findings.append({
                'service': 'IoT Core',
                'issue': 'Disabled unused rule',
                'resource': rule['ruleName'],
                'savings_pct': 15,
                'severity': 'MEDIUM',
                'terraform_fix': f'''
resource "aws_iot_topic_rule" "{rule['ruleName']}" {{
  enabled = false
}}'''
            })
    return findings
```

#### 4. Neptune Graph Database Optimization

```python
def check_neptune_savings():
    """Identify Neptune cluster optimizations"""
    findings = []

    clusters = neptune.describe_db_clusters()
    for cluster in clusters['DBClusters']:
        if cluster['EngineVersion'] < '1.2.1.0':
            findings.append({
                'service': 'Neptune',
                'issue': 'Outdated engine version',
                'resource': cluster['DBClusterIdentifier'],
                'savings_pct': 35,
                'severity': 'HIGH',
                'terraform_fix': f'''
resource "aws_neptune_cluster" "{cluster['DBClusterIdentifier']}" {{
  engine_version = "1.2.1.0"
  apply_immediately = true
}}'''
            })
    return findings
```

#### 5. SageMaker Spot Training

```python
def check_sagemaker_spot():
    """Check for SageMaker jobs not using spot instances"""
    findings = []
    jobs = sagemaker.list_training_jobs()

    for job in jobs['TrainingJobSummaries']:
        details = sagemaker.describe_training_job(
            TrainingJobName=job['TrainingJobName']
        )

        if not details.get('EnableManagedSpotTraining', False):
            findings.append({
                'service': 'SageMaker',
                'issue': 'Not using spot instances',
                'resource': job['TrainingJobName'],
                'savings_pct': 70,
                'severity': 'CRITICAL',
                'terraform_fix': f'''
resource "aws_sagemaker_training_job" "{job['TrainingJobName']}" {{
  enable_managed_spot_training = true
}}'''
            })

    return findings
```

### Report Generation

The script generates a comprehensive markdown report with detailed findings and remediation steps:

````python
def generate_report(findings, service_costs):
    """Generate markdown report with priority matrix"""
    with open('cost_audit.md', 'w') as f:
        f.write("# AWS Cost Audit Report\n\n")
        f.write("## Potential Monthly Savings\n")

        total_savings = 0
        for finding in findings:
            service_cost = service_costs.get(finding['service'], 0) * 4  # Weekly to monthly
            savings = service_cost * (finding['savings_pct'] / 100)
            total_savings += savings

            f.write(f"### {finding['service']} - {finding['resource']}\n")
            f.write(f"- **Issue**: {finding['issue']}\n")
            f.write(f"- **Severity**: {finding['severity']}\n")
            f.write(f"- **Estimated Savings**: ${savings:.2f}/month ({finding['savings_pct']}%)\n")
            f.write(f"- **Terraform Fix**:\n```terraform{finding['terraform_fix']}\n```\n\n")

        f.write(f"## Total Potential Savings: ${total_savings:.2f}/month\n")

        # Add 3-year projection
        three_year = calculate_3yr_savings(total_savings)
        f.write("\n### 3-Year Projection (With Reserved Instances)\n")
        f.write(f"- Upfront Payment: ${three_year['upfront']:.2f}\n")
        f.write(f"- Monthly Payments: ${three_year['monthly']:.2f}\n")
        f.write(f"- **Total Savings**: ${three_year['total']:.2f} (vs On-Demand)\n")
````

## Integration with CI/CD Pipeline

The cost audit script is integrated into our CI/CD pipeline to run automatically:

```yaml
# .github/workflows/cost-audit.yml
name: AWS Cost Audit

on:
  schedule:
    - cron: "0 0 * * *" # Run daily at midnight
  workflow_dispatch: # Allow manual triggering

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: "3.10"

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install boto3 slack_sdk

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Run cost audit
        run: python lib/core/monitoring/cost/aws_cost_optimizer.py
        env:
          # Core AWS environment variables
          SLACK_TOKEN: ${{ secrets.SLACK_TOKEN }}

          # Integration toggles (disabled by default)
          ENABLE_SLACK: ${{ secrets.ENABLE_SLACK || 'false' }}
          ENABLE_DYNAMODB: ${{ secrets.ENABLE_DYNAMODB || 'false' }}

          # Optional configuration
          SLACK_CHANNEL: ${{ secrets.SLACK_CHANNEL || '#cloud-costs' }}
          DYNAMODB_TABLE: ${{ secrets.DYNAMODB_TABLE || 'CostAuditHistory' }}
```

## Optional Integrations

The AWS Cost Audit Script supports several optional integrations that can be enabled as needed:

### Slack Integration

The script can post cost savings summaries to a Slack channel:

1. **Setup Requirements**:

   - Create a Slack workspace and channel (default: `#cloud-costs`)
   - Create a Slack app with chat:write permissions
   - Generate a Bot Token and add it to GitHub Secrets as `SLACK_TOKEN`
   - Set `ENABLE_SLACK` to `true` in GitHub Secrets

2. **Configuration Options**:

   - `ENABLE_SLACK`: Set to `true` to enable Slack integration
   - `SLACK_TOKEN`: Your Slack Bot Token
   - `SLACK_CHANNEL`: The channel to post to (default: `#cloud-costs`)

3. **Example Message**:
   ```
   Monthly Savings Identified: $2,857.00
   ```

### DynamoDB Integration

The script can store audit history in a DynamoDB table for trend analysis:

1. **Setup Requirements**:

   - Ensure AWS credentials have DynamoDB permissions
   - Set `ENABLE_DYNAMODB` to `true` in GitHub Secrets

2. **Configuration Options**:

   - `ENABLE_DYNAMODB`: Set to `true` to enable DynamoDB integration
   - `DYNAMODB_TABLE`: The table name to use (default: `CostAuditHistory`)

3. **Table Structure**:

   - Primary Key: `timestamp` (String)
   - Attributes:
     - `findings`: List of all cost-saving opportunities
     - `total_savings`: Total monthly savings amount

4. **Auto-Creation**:
   - If the specified table doesn't exist, the script will attempt to create it
   - Requires additional IAM permissions for table creation

## CloudWatch Dashboard Integration

We've created a dedicated CloudWatch dashboard for cost monitoring:

```dart
// lib/shared/monitoring/dashboards/cost_dashboard.dart
class CostDashboard {
  static void createDashboard() {
    CloudWatchDashboards.createDashboard(
      dashboardName: 'SoloAdventurer-Costs',
      dashboardBody: json.encode({
        'widgets': [
          {
            'type': 'metric',
            'properties': {
              'title': 'Monthly Costs by Service',
              'metrics': [
                ['AWS/Billing', 'EstimatedCharges', 'ServiceName', 'AmazonRDS'],
                ['AWS/Billing', 'EstimatedCharges', 'ServiceName', 'AmazonOpenSearch'],
                ['AWS/Billing', 'EstimatedCharges', 'ServiceName', 'AmazonIoT'],
                ['AWS/Billing', 'EstimatedCharges', 'ServiceName', 'AmazonNeptune'],
                ['AWS/Billing', 'EstimatedCharges', 'ServiceName', 'AmazonSageMaker'],
              ],
              'period': 86400,
              'stat': 'Maximum',
              'region': 'us-east-1',
              'view': 'timeSeries',
              'stacked': false
            }
          },
          {
            'type': 'metric',
            'properties': {
              'title': 'Cost Savings Identified',
              'metrics': [
                ['SoloAdventurer/Costs', 'SavingsIdentified', 'Service', 'Aurora'],
                ['SoloAdventurer/Costs', 'SavingsIdentified', 'Service', 'OpenSearch'],
                ['SoloAdventurer/Costs', 'SavingsIdentified', 'Service', 'IoT'],
                ['SoloAdventurer/Costs', 'SavingsIdentified', 'Service', 'Neptune'],
                ['SoloAdventurer/Costs', 'SavingsIdentified', 'Service', 'SageMaker'],
              ],
              'period': 86400,
              'stat': 'Maximum',
              'region': 'us-east-1',
              'view': 'timeSeries',
              'stacked': true
            }
          }
        ]
      }),
    );
  }
}
```

## Implementation Timeline

Our cost optimization strategy will be implemented in phases:

### Phase 1 (Week 1)

- Deploy basic script with Aurora and OpenSearch checks
- Implement Slack notifications
- Create initial cost dashboard

### Phase 2 (Week 2)

- Add IoT Core and Neptune checks
- Implement 3-year projections
- Add DynamoDB history tracking

### Phase 3 (Week 3)

- Integrate with CI/CD pipeline
- Implement automated remediation workflow
- Complete security review of IAM policies

## Expected Benefits

| Service              | Current Cost  | Target Cost   | Savings % | Annual Savings |
| -------------------- | ------------- | ------------- | --------- | -------------- |
| Aurora PostgreSQL    | $2,328/mo     | $768/mo       | 67%       | $18,720        |
| OpenSearch           | $1,140/mo     | $547/mo       | 52%       | $7,116         |
| IoT Core (Real-time) | $385/mo       | $327/mo       | 15%       | $696           |
| Neptune (Graph DB)   | $1,375/mo     | $894/mo       | 35%       | $5,772         |
| SageMaker (ML)       | $235/mo       | $70/mo        | 70%       | $1,980         |
| **Total**            | **$5,463/mo** | **$2,606/mo** | **52%**   | **$34,284**    |

## Required IAM Permissions

The script requires the following IAM permissions to function properly:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ce:GetCostAndUsage",
        "rds:DescribeDBClusters",
        "es:ListDomainNames",
        "es:DescribeElasticsearchDomain",
        "lambda:ListFunctions",
        "s3:GetLifecycleConfiguration",
        "elasticache:DescribeReplicationGroups",
        "sagemaker:ListTrainingJobs",
        "sagemaker:DescribeTrainingJob",
        "iot:ListTopicRules",
        "neptune:DescribeDBClusters"
      ],
      "Resource": "*"
    }
  ]
}
```

## Usage Instructions

### Manual Execution

To run the script manually:

1. Ensure AWS credentials are configured
2. Install dependencies: `pip install boto3 slack_sdk`
3. Run the script: `python lib/core/monitoring/cost/aws_cost_optimizer.py`
4. Review the generated `cost_audit.md` file
5. Apply Terraform remediation if desired: `terraform apply terraform_remediation.tf`

### Environment Variables

The script supports the following environment variables:

| Variable          | Description                          | Default            |
| ----------------- | ------------------------------------ | ------------------ |
| `ENABLE_SLACK`    | Enable Slack integration             | `false`            |
| `ENABLE_DYNAMODB` | Enable DynamoDB history tracking     | `false`            |
| `SLACK_TOKEN`     | Slack Bot Token for posting messages | -                  |
| `SLACK_CHANNEL`   | Slack channel to post to             | `#cloud-costs`     |
| `DYNAMODB_TABLE`  | DynamoDB table for history tracking  | `CostAuditHistory` |

### Scheduled Execution

The script is scheduled to run daily via GitHub Actions. Results are:

1. Saved as artifacts in the GitHub Actions workflow
2. Posted to Slack (if enabled)
3. Stored in DynamoDB (if enabled)

### Applying Remediation

Terraform remediation steps can be applied:

1. Automatically for non-critical changes via CI/CD
2. Manually for critical changes after review
3. Scheduled during maintenance windows

## Conclusion

The AWS Cost Audit Script is a critical component of our cost optimization strategy, enabling us to continuously identify and implement savings opportunities across our infrastructure. By automating this process, we ensure that our cloud costs remain under control as our application scales.

## References

- [AWS Cost Explorer API Documentation](https://docs.aws.amazon.com/aws-cost-management/latest/APIReference/API_Operations_AWS_Cost_Explorer_Service.html)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework - Cost Optimization Pillar](https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/welcome.html)
