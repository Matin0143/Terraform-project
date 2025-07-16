#!/bin/bash
yum update -y
yum install -y python3 git

cat > /home/ec2-user/app.py <<EOF
from flask import Flask, request, jsonify
app = Flask(__name__)
@app.route('/process', methods=['POST'])
def process():
    data = request.form.to_dict()
    return jsonify({"status": "received", **data})
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOF

echo "Flask==2.3.2" > /home/ec2-user/requirements.txt
pip3 install -r /home/ec2-user/requirements.txt

nohup python3 /home/ec2-user/app.py > flask.log 2>&1 &
