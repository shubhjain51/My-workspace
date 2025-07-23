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



1- DOCKERFILE

FROM python:3.9-slim
LABEL maintainer="shubhanshujain51@gmail.com"
LABEL version="1.0"
LABEL description="Flask application with Nginx"
WORKDIR /src/app
COPY . /src/app
COPY requirements.txt .
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
RUN  pip install -r requirements.txt
EXPOSE 8080
CMD ['python', 'app.py'] 

docker tag flask-app shubh/flask-app
docker push shubh/flask-app
docker buid -t flask-app .
build run -d -p 8080:80  flask-app  ## 8080 azure ip 80 container ip
