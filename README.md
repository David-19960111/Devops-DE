# Data Engineering DevOps Automation

This project automates the deployment and management of a data engineering pipeline using AWS services. It includes infrastructure as code (Terraform), data generation scripts, and automated testing.

## Architecture

The project consists of the following components:

- **Infrastructure (Terraform)**:
  - S3 bucket for raw data storage
  - AWS Glue database and crawler for data cataloging
  - IAM roles and policies for service access

- **Data Processing**:
  - Sample data generation script
  - Temperature data analysis pipeline

- **CI/CD**:
  - GitHub Actions workflow for automated testing and deployment
  - Multi-stage deployment pipeline (test, validate, plan, deploy)

## Prerequisites

- Python 3.10 or higher
- Terraform 1.5.7 or higher
- AWS CLI configured with appropriate credentials
- GitHub account with repository access

## Installation

1. Clone the repository:
```bash
git clone https://github.com/airscholar/DEDevopsAutomation.git
cd DEDevopsAutomation
```

2. Create and activate a virtual environment:
```bash
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Configure AWS credentials:
```bash
aws configure
```

## Project Structure

```
DEDevopsAutomation/
├── .github/
│   └── workflows/
│       └── deploy.yml      # GitHub Actions workflow
├── scripts/
│   └── generate_sample_data.py  # Data generation script
├── tests/
│   ├── conftest.py        # Pytest configuration
│   └── test_generate_sample_data.py  # Test cases
├── terraform/
│   ├── main.tf           # Main Terraform configuration
│   ├── variables.tf      # Terraform variables
│   ├── outputs.tf        # Terraform outputs
│   ├── provider.tf       # AWS provider configuration
│   └── import_state.sh   # State import script
├── data/                 # Generated data directory
├── requirements.txt      # Python dependencies
└── setup.py             # Python package configuration
```

## Usage

### Data Generation

Generate sample temperature data:
```bash
python scripts/generate_sample_data.py
```

This will create a CSV file in the `data/` directory with temperature records.

### Infrastructure Deployment

1. Initialize Terraform:
```bash
cd terraform
terraform init
```

2. Import existing resources (if any):
```bash
./import_state.sh
```

3. Plan the deployment:
```bash
terraform plan
```

4. Apply the changes:
```bash
terraform apply
```

### Testing

Run the test suite:
```bash
pytest tests/ -v
```

## CI/CD Pipeline

The project uses GitHub Actions for continuous integration and deployment:

1. **Test Stage**: Runs Python tests
2. **Validate Stage**: Checks Terraform configuration
3. **Plan Stage**: Generates Terraform plan
4. **Deploy Stage**: Applies changes to production (only on deploy branch)

## Development Workflow

1. Create a feature branch:
```bash
git checkout -b feature/your-feature
```

2. Make changes and commit:
```bash
git add .
git commit -m "Description of changes"
```

3. Push changes and create a pull request:
```bash
git push origin feature/your-feature
```

4. After PR approval, merge to main branch

## Infrastructure Components

### S3 Bucket
- Stores raw temperature data
- Organized with data/ prefix
- Supports CSV file format

### AWS Glue
- Database for data cataloging
- Crawler for automatic schema detection
- Scheduled to run daily at 1 AM UTC

### IAM Roles
- Glue service role with necessary permissions
- S3 access policies
- Least privilege principle applied