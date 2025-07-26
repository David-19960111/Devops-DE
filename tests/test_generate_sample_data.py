import os
import csv
from datetime import datetime
import pytest
from scripts.generate_sample_data import generate_temperature_csv

@pytest.fixture
def temp_csv_file(tmp_path):
    """Fixture to create a temporary CSV file path."""
    return str(tmp_path / "test_temperature_data.csv")

def test_generate_temperature_csv_creates_file(temp_csv_file):
    """Test if the function creates a CSV file."""
    generate_temperature_csv(temp_csv_file, num_records=10)
    assert os.path.exists(temp_csv_file)

def test_generate_temperature_csv_header(temp_csv_file):
    """Test if the CSV file has the correct header."""
    generate_temperature_csv(temp_csv_file, num_records=1)
    with open(temp_csv_file, 'r') as f:
        reader = csv.reader(f)
        header = next(reader)
        assert header == ["city", "temperature", "timestamp"]

def test_generate_temperature_csv_content(temp_csv_file):
    """Test if the CSV file contains valid data."""
    num_records = 5
    generate_temperature_csv(temp_csv_file, num_records=num_records)
    
    with open(temp_csv_file, 'r') as f:
        reader = csv.reader(f)
        next(reader)  # Skip header
        rows = list(reader)
        
        assert len(rows) == num_records
        
        valid_cities = {"New York", "London", "Tokyo", "Paris", "Sydney"}
        
        for row in rows:
            # Test city
            assert row[0] in valid_cities
            
            # Test temperature
            temp = float(row[1])
            assert -10 <= temp <= 35
            
            # Test timestamp
            timestamp = datetime.fromisoformat(row[2])
            assert isinstance(timestamp, datetime)

def test_generate_temperature_csv_different_sizes(temp_csv_file):
    """Test if the function generates correct number of records."""
    test_sizes = [0, 1, 10, 100]
    
    for size in test_sizes:
        generate_temperature_csv(temp_csv_file, num_records=size)
        with open(temp_csv_file, 'r') as f:
            reader = csv.reader(f)
            next(reader)  # Skip header
            rows = list(reader)
            assert len(rows) == size

def test_generate_temperature_csv_invalid_input(temp_csv_file):
    """Test if the function handles invalid input correctly."""
    with pytest.raises(ValueError):
        generate_temperature_csv(temp_csv_file, num_records=-1)

def test_generate_temperature_csv_file_permissions(tmp_path):
    """Test if the function handles file permission errors correctly."""
    # Create a directory with the same name to cause a permission error
    dir_path = tmp_path / "test_dir.csv"
    dir_path.mkdir()
    
    with pytest.raises(IOError):
        generate_temperature_csv(str(dir_path), num_records=1) 