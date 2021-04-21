FROM localhost:5000/python:3
ENV TZ America/Los_Angeles
WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

CMD [ "python", "./th3-server.py" ]
