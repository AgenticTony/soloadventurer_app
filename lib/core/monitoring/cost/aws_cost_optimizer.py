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
import sys

# Check for demo mode
DEMO_MODE = os.environ.get('DEMO_MODE', 'false').lower() == 'true'

# Configuration flags
ENABLE_SLACK = os.environ.get('ENABLE_SLACK', 'false').lower() == 'true'
ENABLE_DYNAMODB = os.environ.get('ENABLE_DYNAMODB', 'false').lower() == 'true'
SLACK_CHANNEL = os.environ.get('SLACK_CHANNEL', '#cloud-costs')
DYNAMODB_TABLE = os.environ.get('DYNAMODB_TABLE', 'CostAuditHistory')

# Initialize clients
if not DEMO_MODE:
    try:
        cost_explorer = boto3.client('ce')
        rds = boto3.client('rds')
        es = boto3.client('es')
        lambda_client = boto3.client('lambda')
        s3 = boto3.client('s3')
        elasticache = boto3.client('elasticache')
        sagemaker = boto3.client('sagemaker')
        iot = boto3.client('iot')
        neptune = boto3.client('neptune')
    except Exception as e:
        print(f"Error initializing AWS clients: {e}")
        print("If you're testing without AWS credentials, run with DEMO_MODE=true")
        sys.exit(1)

def get_service_costs():
    """Get last 30 days costs grouped by service"""
    if DEMO_MODE:
        # Return mock data for demo mode
        return {
            'Amazon RDS Service': 120.45,
            'Amazon OpenSearch Service': 85.32,
            'AWS Lambda': 25.67,
            'Amazon S3': 18.90,
            'Amazon ElastiCache': 45.78,
            'Amazon SageMaker': 150.23,
            'AWS IoT': 12.45,
            'Amazon Neptune': 95.67
        }
    
    end = datetime.utcnow()
    start = end - timedelta(days=30)
    
    response = cost_explorer.get_cost_and_usage(
        TimePeriod={
            'Start': start.strftime('%Y-%m-%d'),
            'End': end.strftime('%Y-%m-%d')
        },
        Granularity='DAILY',
        Metrics=['UnblendedCost'],
        GroupBy=[{'Type': 'DIMENSION', 'Key': 'SERVICE'}]
    )
    
    return {item['Keys'][0]: float(item['Metrics']['UnblendedCost']['Amount'])
            for item in response['ResultsByTime'][0]['Groups']}

def check_aurora_savings():
    """Identify Aurora cost savings opportunities"""
    if DEMO_MODE:
        # Return mock findings for demo mode
        return [{
            'service': 'Amazon RDS Service',
            'issue': 'Non-serverless cluster',
            'resource': 'soloadventurer-prod',
            'savings_pct': 67,
            'severity': 'CRITICAL',
            'terraform_fix': '''
resource "aws_rds_cluster" "soloadventurer-prod" {
  engine_mode         = "serverlessv2"
  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 16
  }
}'''
        }]
    
    findings = []
    clusters = rds.describe_db_clusters()
    
    for cluster in clusters['DBClusters']:
        if cluster['EngineMode'] != 'serverlessv2':
            savings_pct = 67 if cluster['EngineMode'] == 'provisioned' else 40
            findings.append({
                'service': 'Amazon RDS Service',
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

def check_opensearch_graviton():
    """Check for non-Graviton OpenSearch instances"""
    if DEMO_MODE:
        # Return mock findings for demo mode
        return [{
            'service': 'Amazon OpenSearch Service',
            'issue': 'Non-Graviton instances',
            'resource': 'soloadventurer-search',
            'savings_pct': 52,
            'severity': 'HIGH',
            'terraform_fix': '''
resource "aws_elasticsearch_domain" "soloadventurer-search" {
  cluster_config {
    instance_type = "r6g.large.search"
    instance_count = 2
  }
}'''
        }]
    
    findings = []
    domains = es.list_domain_names()
    
    for domain in domains['DomainNames']:
        config = es.describe_elasticsearch_domain(
            DomainName=domain['DomainName']
        )['DomainStatus']
        
        if 'r6g' not in config['ElasticsearchClusterConfig']['InstanceType']:
            findings.append({
                'service': 'Amazon OpenSearch Service',
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

def check_iot_core_savings():
    """Identify IoT Core optimization opportunities"""
    if DEMO_MODE:
        # Return mock findings for demo mode
        return [{
            'service': 'AWS IoT',
            'issue': 'Disabled unused rule',
            'resource': 'location_tracking_rule',
            'savings_pct': 15,
            'severity': 'MEDIUM',
            'terraform_fix': '''
resource "aws_iot_topic_rule" "location_tracking_rule" {
  enabled = false
}'''
        }]
    
    findings = []
    
    # Check for unused topics
    topics = iot.list_topic_rules()
    for rule in topics['rules']:
        if rule['ruleDisabled']:
            findings.append({
                'service': 'AWS IoT',
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

def check_neptune_savings():
    """Identify Neptune cluster optimizations"""
    if DEMO_MODE:
        # Return mock findings for demo mode
        return [{
            'service': 'Amazon Neptune',
            'issue': 'Outdated engine version',
            'resource': 'soloadventurer-graph',
            'savings_pct': 35,
            'severity': 'HIGH',
            'terraform_fix': '''
resource "aws_neptune_cluster" "soloadventurer-graph" {
  engine_version = "1.2.1.0"
  apply_immediately = true
}'''
        }]
    
    findings = []
    
    clusters = neptune.describe_db_clusters()
    for cluster in clusters['DBClusters']:
        if cluster['EngineVersion'] < '1.2.1.0':
            findings.append({
                'service': 'Amazon Neptune',
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

def check_sagemaker_spot():
    """Check for SageMaker jobs not using spot instances"""
    if DEMO_MODE:
        # Return mock findings for demo mode
        return [{
            'service': 'Amazon SageMaker',
            'issue': 'Not using spot instances',
            'resource': 'matching-model-training',
            'savings_pct': 70,
            'severity': 'CRITICAL',
            'terraform_fix': '''
resource "aws_sagemaker_training_job" "matching-model-training" {
  enable_managed_spot_training = true
}'''
        }]
    
    findings = []
    jobs = sagemaker.list_training_jobs()
    
    for job in jobs['TrainingJobSummaries']:
        details = sagemaker.describe_training_job(
            TrainingJobName=job['TrainingJobName']
        )
        
        if not details.get('EnableManagedSpotTraining', False):
            findings.append({
                'service': 'Amazon SageMaker',
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

def calculate_3yr_savings(total_monthly):
    """Calculate 3-year Reserved Instance savings"""
    upfront_payment = total_monthly * 0.4 * 36  # 40% upfront discount
    monthly_payments = total_monthly * 0.6 * 36
    return {
        'upfront': upfront_payment,
        'monthly': monthly_payments,
        'total': upfront_payment + monthly_payments
    }

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
        
        # Add breakdown by service
        f.write("\nBreakdown by Service:\n")
        f.write("| Service | Monthly Savings | Severity |\n")
        f.write("|---------|-----------------|----------|\n")
        for finding in findings:
            service_cost = service_costs.get(finding['service'], 0) * 4
            savings = service_cost * (finding['savings_pct'] / 100)
            f.write(f"| {finding['service']} | ${savings:.2f} | {finding['severity']} |\n")

def post_to_slack(savings):
    """Post savings summary to Slack"""
    if not ENABLE_SLACK:
        print("Slack integration disabled. Skipping post to Slack.")
        return
        
    slack_token = os.environ.get('SLACK_TOKEN')
    if not slack_token:
        print("SLACK_TOKEN environment variable not set. Skipping post to Slack.")
        return
        
    try:
        from slack_sdk import WebClient
        client = WebClient(token=slack_token)
        client.chat_postMessage(
            channel=SLACK_CHANNEL,
            text=f"Monthly Savings Identified: ${savings:.2f}"
        )
        print(f"Successfully posted savings summary to Slack channel {SLACK_CHANNEL}")
    except ImportError:
        print("slack_sdk package not installed. Run 'pip install slack_sdk' to enable Slack integration.")
    except Exception as e:
        print(f"Error posting to Slack: {e}")

def save_to_dynamodb(findings, total_savings):
    """Save audit history to DynamoDB"""
    if not ENABLE_DYNAMODB:
        print("DynamoDB integration disabled. Skipping history save.")
        return
        
    try:
        # Check if table exists first
        dynamodb = boto3.resource('dynamodb')
        try:
            dynamodb.meta.client.describe_table(TableName=DYNAMODB_TABLE)
        except dynamodb.meta.client.exceptions.ResourceNotFoundException:
            print(f"DynamoDB table {DYNAMODB_TABLE} does not exist. Creating table...")
            table = dynamodb.create_table(
                TableName=DYNAMODB_TABLE,
                KeySchema=[
                    {
                        'AttributeName': 'timestamp',
                        'KeyType': 'HASH'
                    }
                ],
                AttributeDefinitions=[
                    {
                        'AttributeName': 'timestamp',
                        'AttributeType': 'S'
                    }
                ],
                ProvisionedThroughput={
                    'ReadCapacityUnits': 5,
                    'WriteCapacityUnits': 5
                }
            )
            # Wait for table creation
            table.meta.client.get_waiter('table_exists').wait(TableName=DYNAMODB_TABLE)
            print(f"Table {DYNAMODB_TABLE} created successfully.")
        
        # Now save the data
        table = dynamodb.Table(DYNAMODB_TABLE)
        table.put_item(Item={
            'timestamp': datetime.now().isoformat(),
            'findings': json.loads(json.dumps(findings, default=str)),  # Convert to JSON-serializable format
            'total_savings': float(total_savings)
        })
        print(f"Successfully saved audit history to DynamoDB table {DYNAMODB_TABLE}")
    except Exception as e:
        print(f"Error saving to DynamoDB: {e}")

def generate_terraform_file(findings):
    """Generate Terraform remediation file"""
    with open('terraform_remediation.tf', 'w') as f:
        f.write("# AWS Cost Optimization - Terraform Remediation\n")
        f.write("# Generated on: " + datetime.now().strftime("%Y-%m-%d %H:%M:%S") + "\n\n")
        
        for finding in findings:
            f.write(f"# {finding['service']} - {finding['resource']}\n")
            f.write(f"# Issue: {finding['issue']}\n")
            f.write(f"# Severity: {finding['severity']}\n")
            f.write(f"# Savings: {finding['savings_pct']}%\n")
            f.write(finding['terraform_fix'] + "\n\n")

def main():
    """Main function to run the cost audit"""
    print("Starting AWS Cost Audit...")
    
    if DEMO_MODE:
        print("Running in DEMO MODE - using mock data")
    
    # Get service costs
    service_costs = get_service_costs()
    
    # Collect findings from all checks
    findings = []
    findings.extend(check_aurora_savings())
    findings.extend(check_opensearch_graviton())
    findings.extend(check_iot_core_savings())
    findings.extend(check_neptune_savings())
    findings.extend(check_sagemaker_spot())
    
    # Calculate total potential savings
    total_savings = 0
    for finding in findings:
        service_cost = service_costs.get(finding['service'], 0) * 4  # Weekly to monthly
        savings = service_cost * (finding['savings_pct'] / 100)
        total_savings += savings
    
    # Generate report
    generate_report(findings, service_costs)
    
    # Generate Terraform remediation file
    generate_terraform_file(findings)
    
    # Post to Slack if enabled
    post_to_slack(total_savings)
    
    # Save to DynamoDB if enabled
    save_to_dynamodb(findings, total_savings)
    
    print(f"AWS Cost Audit completed. Potential monthly savings: ${total_savings:.2f}")
    print("Reports generated: cost_audit.md, terraform_remediation.tf")

if __name__ == "__main__":
    main() 