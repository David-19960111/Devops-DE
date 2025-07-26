import csv 
from datetime import datetime, timedelta
import random
import os 

def generate_temperature_csv(filename, num_records=10000):
    """
    Generate a CSV file with random temperature data.
    
    Args:
        filename (str): Path to the output CSV file
        num_records (int): Number of records to generate (default: 10000)
        
    Raises:
        ValueError: If num_records is negative
        IOError: If file cannot be created or written to
    """
    if num_records < 0:
        raise ValueError("Number of recors cannot be negative")
    
    cities = ["New York", "London", "Tokyo", "Paris", "Sydney"]
    header = ["city", "temperature", "timestamp"]

    #Create directory if it doesn't exit
    os.makedirs(os.path.dirname(filename), exist_ok=True)

    try:
        with open(filename, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(header)

            for _ in range(num_records):
                city = random.choice(cities)
                temp = round(random.uniform(-10, 35), 1)
                time = datetime.now() - timedelta(days=random.randint(0, 365))

                writer.writerow([
                    city,
                    temp,
                    time.isoformat()
                ])
    except (IOError, OSError) as e:
        raise IOError(f"failed to write to file {filename}: {str(e)}")
    
if __name__ == "__main__":
    generate_temperature_csv("data/temperatue_data.csv")
            