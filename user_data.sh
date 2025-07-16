#!/bin/bash
# Update and install packages
yum update -y
yum install -y python3 git

# Install Node.js (LTS)
curl -sL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Clone your repo (or assume it's bundled in AMI)
cd /home/ec2-user

# Flask Setup
mkdir flask && cd flask
cat > app.py <<EOF
from flask import Flask, request, jsonify
app = Flask(__name__)
@app.route('/process', methods=['POST'])
def process():
    data = request.form.to_dict()
    return jsonify({"status": "received", **data})
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOF

echo "Flask==2.3.2" > requirements.txt
pip3 install -r requirements.txt

# Run Flask app
nohup python3 app.py > flask.log 2>&1 &

# Express Setup
cd /home/ec2-user
mkdir express && cd express

cat > package.json <<EOF
{
  "name": "express-app",
  "version": "1.0.0",
  "main": "src/index.js",
  "dependencies": {
    "express": "^4.18.2",
    "axios": "^1.4.0"
  }
}
EOF

mkdir -p src && cd src
cat > index.js <<EOF
const express = require('express');
const axios = require('axios');
const app = express();
app.use(express.urlencoded({ extended: true }));
app.get('/', (req, res) => {
  res.send(\`
    <form action="/submit" method="POST">
      <input name="name" />
      <input name="email" />
      <button>Submit</button>
    </form>
  \`);
});
app.post('/submit', async (req, res) => {
  const response = await axios.post('http://localhost:5000/process', req.body);
  res.send(response.data);
});
app.listen(3000, () => console.log('Express running on port 3000'));
EOF

cd ..
npm install

# Run Express app
nohup node src/index.js > express.log 2>&1 &
