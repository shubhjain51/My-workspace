# ---------- Stage 1: Builder ----------
FROM python:3.9-slim AS builder

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies into a temporary location
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# ---------- Stage 2: Final image ----------
FROM python:3.9-slim AS final

# Set working directory
WORKDIR /app

# Copy installed packages from builder stage
COPY --from=builder /root/.local /root/.local

# Ensure local Python user-installed bin directory is in PATH
ENV PATH=/root/.local/bin:$PATH

# Copy app source code
COPY . .

# Expose the port the app runs on
EXPOSE 5000

# Run the app
CMD ["python", "app.py"]
