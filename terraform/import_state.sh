#!/bin/bash

# Set variables
PROJECT_NAME="dml-temperature-analysis"
AWS_ACCOUNT_ID="12345678901212"  # Your AWS Account ID

echo "Starting Terraform state import..."

# Initialize Terraform
terraform init

# Function to check if resource exists
check_resource_exists() {
    local resource_type=$1
    local resource_name=$2
    echo "Checking if $resource_type '$resource_name' exists..."
    
    case $resource_type in
        "iam")
            if aws iam get-role --role-name "$resource_name" 2>/dev/null; then
                return 0
            fi
            ;;
        "glue")
            if aws glue get-database --name "$resource_name" 2>/dev/null; then
                return 0
            fi
            ;;
        "glue_crawler")
            if aws glue get-crawler --name "$resource_name" 2>/dev/null; then
                return 0
            fi
            ;;
        "s3")
            if aws s3 ls "s3://$resource_name" 2>/dev/null; then
                return 0
            fi
            ;;
        "s3_object")
            if aws s3 ls "s3://$resource_name" 2>/dev/null; then
                return 0
            fi
            ;;
    esac
    return 1
}

# Function to check if resource is in state
check_resource_in_state() {
    local resource_type=$1
    local resource_name=$2
    if terraform state list | grep -q "^$resource_type\.$resource_name$"; then
        return 0
    fi
    return 1
}

# Function to remove resource from state
remove_from_state() {
    local resource_type=$1
    local resource_name=$2
    echo "Removing $resource_type.$resource_name from state..."
    terraform state rm "$resource_type.$resource_name"
}

# Function to clean up state
cleanup_state() {
    echo "Cleaning up state..."
    # Remove any resources that don't exist anymore
    for resource in $(terraform state list); do
        case $resource in
            "aws_glue_crawler.main")
                if ! check_resource_exists "glue_crawler" "${PROJECT_NAME}-crawler"; then
                    remove_from_state "aws_glue_crawler" "main"
                fi
                ;;
            "aws_s3_object.data_directory")
                if ! check_resource_exists "s3_object" "${PROJECT_NAME}-raw-data/data/"; then
                    remove_from_state "aws_s3_object" "data_directory"
                fi
                ;;
            "aws_s3_object.temperature_data")
                if ! check_resource_exists "s3_object" "${PROJECT_NAME}-raw-data/data/temperature_data.csv"; then
                    remove_from_state "aws_s3_object" "temperature_data"
                fi
                ;;
            "null_resource.empty_s3_bucket")
                remove_from_state "null_resource" "empty_s3_bucket"
                ;;
        esac
    done
}

# Function to create data directory and sample file
create_data_files() {
    echo "Creating data directory and sample file..."
    mkdir -p ../data
    if [ ! -f "../data/temperature_data.csv" ]; then
        echo "date,temperature,location" > "../data/temperature_data.csv"
        echo "2024-01-01,25.5,New York" >> "../data/temperature_data.csv"
        echo "2024-01-02,26.0,New York" >> "../data/temperature_data.csv"
    fi
}

# Clean up state first
cleanup_state

# Create necessary data files
create_data_files

# Import S3 bucket and its configurations
echo "Importing S3 bucket and configurations..."
if check_resource_exists "s3" "${PROJECT_NAME}-raw-data"; then
    # Import the bucket
    if ! check_resource_in_state "aws_s3_bucket" "raw_data"; then
        terraform import aws_s3_bucket.raw_data "${PROJECT_NAME}-raw-data"
    else
        echo "S3 bucket already in state"
    fi
    
    # Import bucket versioning
    if ! check_resource_in_state "aws_s3_bucket_versioning" "raw_data"; then
        terraform import aws_s3_bucket_versioning.raw_data "${PROJECT_NAME}-raw-data"
    else
        echo "S3 bucket versioning already in state"
    fi
    
    # Import bucket encryption
    if ! check_resource_in_state "aws_s3_bucket_server_side_encryption_configuration" "raw_data"; then
        terraform import aws_s3_bucket_server_side_encryption_configuration.raw_data "${PROJECT_NAME}-raw-data"
    else
        echo "S3 bucket encryption already in state"
    fi
else
    echo "S3 bucket ${PROJECT_NAME}-raw-data does not exist"
fi

# Import IAM role and policy attachments
echo "Importing IAM role and policy attachments..."
if check_resource_exists "iam" "AWSGlueServiceRole-${PROJECT_NAME}"; then
    # Import the role
    if ! check_resource_in_state "aws_iam_role" "glue_role"; then
        terraform import aws_iam_role.glue_role "AWSGlueServiceRole-${PROJECT_NAME}"
    else
        echo "IAM role already in state"
    fi
    
    # Import policy attachments
    if ! check_resource_in_state "aws_iam_role_policy_attachment" "glue_service_role"; then
        terraform import aws_iam_role_policy_attachment.glue_service_role "AWSGlueServiceRole-${PROJECT_NAME}/arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
    else
        echo "IAM role service policy attachment already in state"
    fi
    
    if ! check_resource_in_state "aws_iam_role_policy_attachment" "glue_s3_access"; then
        terraform import aws_iam_role_policy_attachment.glue_s3_access "AWSGlueServiceRole-${PROJECT_NAME}/arn:aws:iam::aws:policy/AmazonS3FullAccess"
    else
        echo "IAM role S3 policy attachment already in state"
    fi
else
    echo "IAM role AWSGlueServiceRole-${PROJECT_NAME} does not exist"
fi

# Import Glue database
echo "Importing Glue database..."
if check_resource_exists "glue" "${PROJECT_NAME}_catalog"; then
    if ! check_resource_in_state "aws_glue_catalog_database" "main"; then
        terraform import aws_glue_catalog_database.main "${AWS_ACCOUNT_ID}:${PROJECT_NAME}_catalog"
    else
        echo "Glue database already in state"
    fi
else
    echo "Glue database ${PROJECT_NAME}_catalog does not exist"
fi

# Import Glue crawler
echo "Importing Glue crawler..."
if check_resource_exists "glue_crawler" "${PROJECT_NAME}-crawler"; then
    if ! check_resource_in_state "aws_glue_crawler" "main"; then
        terraform import aws_glue_crawler.main "${PROJECT_NAME}-crawler"
    else
        echo "Glue crawler already in state"
    fi
else
    echo "Glue crawler ${PROJECT_NAME}-crawler does not exist, will be created"
fi