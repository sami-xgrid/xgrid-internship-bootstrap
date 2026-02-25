FROM python:3.9-slim

WORKDIR /app

# Create a non-root user for security
RUN useradd -m appuser

RUN pip install --no-cache-dir flask

COPY app.py .

# Change ownership of the app folder to our non-root user
RUN chown -R appuser:appuser /app

# Switch to the non-root user
USER appuser

# Expose the port the app runs on
EXPOSE 4000

# Run the application
CMD ["python", "app.py"]