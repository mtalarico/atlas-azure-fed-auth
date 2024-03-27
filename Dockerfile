FROM python:3

WORKDIR /usr/src/app

COPY oidc.py requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
CMD [ "/bin/sleep", "3650d" ]
