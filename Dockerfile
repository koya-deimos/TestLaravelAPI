# Use the official Python image as the base image
FROM python:3.10-slim

# Set working directory
WORKDIR /usr/src/app

# Install any dependencies
RUN pip install Flask

# Create a simple Flask application
RUN echo 'from flask import Flask\n\
app = Flask(__name__)\n\
@app.route("/")\n\
def hello():\n\
    return "Hello, World!"\n\
if __name__ == "__main__":\n\
    app.run(host="0.0.0.0", port=5000)' > app.py

# Expose port 5000
EXPOSE 5000

# Command to run the application
CMD ["python", "app.py"]