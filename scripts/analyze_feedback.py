#!/usr/bin/env python3

"""
SoloAdventurer Feedback Analysis Script
This script analyzes user feedback data from CSV files and generates reports.
"""

import os
import sys
import csv
import json
import argparse
from datetime import datetime
from collections import Counter, defaultdict
import matplotlib.pyplot as plt
import pandas as pd

# Check if required packages are installed
try:
    import pandas as pd
    import matplotlib.pyplot as plt
except ImportError:
    print("Required packages not found. Please install them using:")
    print("pip install pandas matplotlib")
    sys.exit(1)

class FeedbackAnalyzer:
    """Class to analyze user feedback data for the SoloAdventurer app."""
    
    def __init__(self, input_file=None, output_dir="feedback_reports"):
        """Initialize the feedback analyzer with input file and output directory."""
        self.input_file = input_file
        self.output_dir = output_dir
        self.data = None
        self.report_date = datetime.now().strftime("%Y-%m-%d")
        
        # Create output directory if it doesn't exist
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
    
    def load_data(self, file_path=None):
        """Load feedback data from CSV file."""
        if file_path:
            self.input_file = file_path
        
        if not self.input_file:
            raise ValueError("No input file specified")
        
        try:
            self.data = pd.read_csv(self.input_file)
            print(f"Loaded {len(self.data)} feedback entries from {self.input_file}")
            return True
        except Exception as e:
            print(f"Error loading data: {e}")
            return False
    
    def generate_summary(self):
        """Generate a summary of the feedback data."""
        if self.data is None:
            print("No data loaded. Please load data first.")
            return None
        
        summary = {
            "total_entries": len(self.data),
            "date_generated": self.report_date,
            "source_file": self.input_file
        }
        
        # Add rating statistics if 'rating' column exists
        if 'rating' in self.data.columns:
            summary["average_rating"] = self.data['rating'].mean()
            summary["rating_distribution"] = self.data['rating'].value_counts().to_dict()
        
        # Add category statistics if 'category' column exists
        if 'category' in self.data.columns:
            summary["category_distribution"] = self.data['category'].value_counts().to_dict()
        
        return summary
    
    def extract_common_terms(self, text_column='feedback', top_n=10):
        """Extract most common terms from feedback text."""
        if self.data is None or text_column not in self.data.columns:
            return {}
        
        # Combine all feedback text
        all_text = " ".join(self.data[text_column].dropna().astype(str))
        
        # Simple tokenization (split by space and remove common punctuation)
        words = all_text.lower().replace('.', ' ').replace(',', ' ').replace('!', ' ').replace('?', ' ').split()
        
        # Filter out common stop words (a very basic list)
        stop_words = {'the', 'a', 'an', 'and', 'or', 'but', 'is', 'are', 'was', 'were', 
                      'in', 'on', 'at', 'to', 'for', 'with', 'by', 'about', 'like', 'of', 'i', 'my'}
        filtered_words = [word for word in words if word not in stop_words and len(word) > 2]
        
        # Count occurrences
        word_counts = Counter(filtered_words)
        
        # Return top N words
        return dict(word_counts.most_common(top_n))
    
    def generate_time_trend(self, date_column='date', metric_column='rating'):
        """Generate time trend analysis of feedback metrics."""
        if self.data is None or date_column not in self.data.columns or metric_column not in self.data.columns:
            return None
        
        # Convert date column to datetime
        try:
            self.data[date_column] = pd.to_datetime(self.data[date_column])
        except:
            print(f"Error converting {date_column} to datetime format")
            return None
        
        # Group by date and calculate average of the metric
        time_trend = self.data.groupby(self.data[date_column].dt.date)[metric_column].mean()
        
        return time_trend.to_dict()
    
    def plot_rating_distribution(self, save_path=None):
        """Plot the distribution of ratings."""
        if self.data is None or 'rating' not in self.data.columns:
            print("No rating data available")
            return
        
        plt.figure(figsize=(10, 6))
        self.data['rating'].value_counts().sort_index().plot(kind='bar', color='skyblue')
        plt.title('Distribution of Feedback Ratings')
        plt.xlabel('Rating')
        plt.ylabel('Count')
        plt.grid(axis='y', linestyle='--', alpha=0.7)
        
        if save_path:
            plt.savefig(save_path)
            print(f"Rating distribution plot saved to {save_path}")
        else:
            save_path = os.path.join(self.output_dir, f"rating_distribution_{self.report_date}.png")
            plt.savefig(save_path)
            print(f"Rating distribution plot saved to {save_path}")
        
        plt.close()
    
    def plot_category_distribution(self, save_path=None):
        """Plot the distribution of feedback categories."""
        if self.data is None or 'category' not in self.data.columns:
            print("No category data available")
            return
        
        plt.figure(figsize=(12, 7))
        category_counts = self.data['category'].value_counts()
        category_counts.plot(kind='pie', autopct='%1.1f%%', startangle=90, 
                            colors=plt.cm.Paired(range(len(category_counts))))
        plt.title('Feedback by Category')
        plt.ylabel('')  # Hide the ylabel
        plt.axis('equal')  # Equal aspect ratio ensures that pie is drawn as a circle
        
        if save_path:
            plt.savefig(save_path)
            print(f"Category distribution plot saved to {save_path}")
        else:
            save_path = os.path.join(self.output_dir, f"category_distribution_{self.report_date}.png")
            plt.savefig(save_path)
            print(f"Category distribution plot saved to {save_path}")
        
        plt.close()
    
    def generate_full_report(self):
        """Generate a comprehensive feedback analysis report."""
        if self.data is None:
            print("No data loaded. Please load data first.")
            return
        
        # Create report dictionary
        report = {
            "summary": self.generate_summary(),
            "common_terms": self.extract_common_terms(),
            "time_trend": self.generate_time_trend() if 'date' in self.data.columns and 'rating' in self.data.columns else None
        }
        
        # Save report as JSON
        report_path = os.path.join(self.output_dir, f"feedback_report_{self.report_date}.json")
        with open(report_path, 'w') as f:
            json.dump(report, f, indent=4)
        
        print(f"Full report saved to {report_path}")
        
        # Generate plots
        if 'rating' in self.data.columns:
            self.plot_rating_distribution()
        
        if 'category' in self.data.columns:
            self.plot_category_distribution()
        
        return report
    
    def create_sample_data(self, output_file="sample_feedback.csv", num_entries=100):
        """Create sample feedback data for testing."""
        import random
        from datetime import timedelta
        
        categories = ["UI/UX", "Performance", "Features", "Bugs", "Content"]
        feedback_templates = [
            "I love the {aspect} of this app!",
            "The {aspect} needs improvement.",
            "Could you please fix the {aspect}?",
            "Great job on the {aspect}!",
            "I'm having trouble with the {aspect}."
        ]
        aspects = ["interface", "speed", "reliability", "design", "functionality", 
                  "user experience", "navigation", "search feature", "profile page",
                  "trip planning", "matching algorithm", "map integration"]
        
        # Generate sample data
        data = []
        start_date = datetime.now() - timedelta(days=90)
        
        for i in range(num_entries):
            entry_date = start_date + timedelta(days=random.randint(0, 90))
            rating = random.randint(1, 5)
            category = random.choice(categories)
            feedback_template = random.choice(feedback_templates)
            aspect = random.choice(aspects)
            feedback = feedback_template.replace("{aspect}", aspect)
            
            data.append({
                "date": entry_date.strftime("%Y-%m-%d"),
                "rating": rating,
                "category": category,
                "feedback": feedback,
                "user_id": f"user_{random.randint(1000, 9999)}"
            })
        
        # Write to CSV
        with open(output_file, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=data[0].keys())
            writer.writeheader()
            writer.writerows(data)
        
        print(f"Created sample feedback data with {num_entries} entries at {output_file}")
        return output_file

def main():
    """Main function to run the feedback analyzer from command line."""
    parser = argparse.ArgumentParser(description="Analyze user feedback for SoloAdventurer app")
    parser.add_argument("-i", "--input", help="Input CSV file with feedback data")
    parser.add_argument("-o", "--output", default="feedback_reports", help="Output directory for reports")
    parser.add_argument("-s", "--sample", action="store_true", help="Create sample data for testing")
    parser.add_argument("-n", "--num_samples", type=int, default=100, help="Number of sample entries to create")
    
    args = parser.parse_args()
    
    analyzer = FeedbackAnalyzer(args.input, args.output)
    
    if args.sample:
        sample_file = analyzer.create_sample_data(num_entries=args.num_samples)
        analyzer.load_data(sample_file)
    elif args.input:
        analyzer.load_data()
    else:
        parser.print_help()
        return
    
    analyzer.generate_full_report()

if __name__ == "__main__":
    main() 