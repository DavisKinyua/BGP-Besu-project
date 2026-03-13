FROM python:3.9-slim

WORKDIR /app

# Install system dependencies (optional, but good for debugging)
RUN apt-get update && apt-get install -y iputils-ping curl bird2 && rm -rf /var/lib/apt/lists/*

# Install Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install web3

# Copy the scripts
COPY . .


# Default command (overridden in docker-compose)
CMD ["python", "uni_guard.py"]