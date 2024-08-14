from flask import Flask, send_from_directory

app = Flask(__name__, static_folder='', static_url_path='')

@app.route('/')
def home():
    return app.send_static_file('index.html')

@app.route('/elements')
def elements():
    return app.send_static_file('elements.html')

@app.route('/generic')
def generic():
    return app.send_static_file('generic.html')

# Routes for assets and images
@app.route('/assets/<path:path>')
def send_assets(path):
    return send_from_directory('assets', path)

@app.route('/images/<path:path>')
def send_images(path):
    return send_from_directory('images', path)

if __name__ == '__main__':
    app.run(debug=True, port=5000)

