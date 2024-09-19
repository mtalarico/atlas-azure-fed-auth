FROM python:3

WORKDIR /usr/src/app

COPY oidc.py requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
CMD ["python", "-c", "import time; time.sleep(8640000)"]
