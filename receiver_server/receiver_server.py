# receiver_server.py
from flask import Flask, request, jsonify

app = Flask(__name__)

# --- Old /send-text endpoint (optional, you can keep or remove) ---
@app.route('/send-text', methods=['POST'])
def receive_text():
    if request.is_json:
        data = request.get_json()
        received_message = data.get('message')
        if received_message:
            print(f"Received message from phone (Text Endpoint): '{received_message}'")
            return jsonify({"status": "success", "message": "Text received!"}), 200
        else:
            return jsonify({"status": "error", "message": "No 'message' key found in JSON"}), 400
    else:
        return jsonify({"status": "error", "message": "Request must be JSON"}), 400

# --- New /send-coordinates endpoint ---
@app.route('/send-coordinates', methods=['POST'])
def receive_coordinates():
    """
    This endpoint listens for POST requests to the '/send-coordinates' URL.
    It expects JSON data with 'latitude' and 'longitude' keys.~
    It prints the received coordinates to the console.
    """
    if request.is_json:
        data = request.get_json()
        latitude = data.get('latitude')
        longitude = data.get('longitude')

        if latitude is not None and longitude is not None:
            print(f"Received coordinates from phone: Lat={latitude}, Lon={longitude}")
            return jsonify({"status": "success", "message": "Coordinates received!"}), 200
        else:
            return jsonify({"status": "error", "message": "Missing 'latitude' or 'longitude' in JSON"}), 400
    else:
        return jsonify({"status": "error", "message": "Request must be JSON"}), 400

# Root endpoint (GET requests)
@app.route('/', methods=['GET'])
def root():
    return "Network Test Server is running! Send POST requests to /send-coordinates", 200

if __name__ == '__main__':
    # Run the Flask app on all available interfaces on port 5000
    app.run(host='0.0.0.0', port=5000, debug=True)
    print("Flask server started. Listening on http://0.0.0.0:5000")
