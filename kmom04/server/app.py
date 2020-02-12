#!/usr/bin/env python3

from flask import Flask, render_template, request
from flask_request_params import bind_request_params

import json
app = Flask(__name__)

app.before_request(bind_request_params)

with open('data/items.json', 'r+', encoding="utf-8") as json_file:
    data = json.load(json_file)

@app.route('/')
def index():

    return render_template("index.html")

@app.route('/all')
def all():
    return data

@app.route('/names')
def names():
    """ Names route """
    name_list = []
    for value in data["items"]:
        name_list.append(value["name"])
    
    return render_template("names.html", names=name_list)


@app.route('/color/<col>', methods=['GET', 'POST'])
def color(col):
    col = request.params
    searchColor = col["col"]

    result = []

    for items in data["items"]:
        if (searchColor.capitalize() in items["color"]):
            result.append(items)


    return render_template("color.html", result=result)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
