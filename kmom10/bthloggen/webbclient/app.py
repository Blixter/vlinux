#!/usr/bin/env python3

from flask import Flask, render_template, request
from flask_request_params import bind_request_params
import requests

import json
app = Flask(__name__)

app.before_request(bind_request_params)

@app.route('/')
def main():
    """ Home route """
    return render_template("index.html")

@app.route('/data')
def data():
    """ Data route """
    header="All data"
    response = requests.get('http://server:1337/data')
    return render_template("result.html", result=response.json(), header=header)

@app.route('/search', methods=['POST', 'GET'])
def search():
    """ Search route """
    if request.method == 'POST':
        header="Search Result"
        query = ""
        data = request.form.to_dict()
        for key in data:
            if data[key]:
                query += key + "=" + data[key] + "&"
        
        response = requests.get('http://server:1337/data?' + query)
        
        return render_template("result.html", result=response.json(), header=header)

    return render_template("search.html")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=1338)
