from flask import Flask, render_template, request
from upload import *

application = Flask(__name__)
@application.route('/')
def index():
    return 'Web App with Python Flask!'


@application.route("/upload", methods=['POST', 'GET'])
def upload():
        if request.method == 'POST':
            f = request.files['file']
            print(f)
            file_name = upload_my_file(f)
            print(file_name)
       
        return render_template('uploads3.html')

if __name__=='__main__':
    application.run(host='0.0.0.0', port=8080, debug=True)