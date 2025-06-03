from flask import Flask, request, jsonify
import tensorflow as tf
import numpy as np
import json
from tensorflow.keras.models import model_from_json
from PIL import Image
import io
import cv2
from mtcnn import MTCNN

app = Flask(__name__)

# Load model architecture from JSON
with open("../models/jsonfile.json", "r") as json_file:
    model_json = json_file.read()
    model = model_from_json(model_json)

# Load model weights from .h5 file
model.load_weights("../models/emotion_model.weights.h5")

# Initialize MTCNN face detector (removed thresholds argument)
detector = MTCNN(min_face_size=40)  # Adjusted min_face_size

# Detect and crop face using MTCNN
def detect_and_crop_face(image_bytes):
    # Convert image to numpy array
    image = np.array(Image.open(io.BytesIO(image_bytes)))

    # Convert image to BGR (OpenCV format)
    image_resized = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)

    # Use MTCNN to detect faces
    faces = detector.detect_faces(image_resized)

    # Debugging: Log the number of faces detected
    print(f"Faces detected: {len(faces)}")

    # Check if no face is detected
    if len(faces) == 0:
        print("No face detected in the image.")
        return None, "No face detected"

    # Select the largest detected face (based on area)
    largest_face = max(faces, key=lambda x: x['box'][2] * x['box'][3])
    x, y, w, h = largest_face['box']
    face = image_resized[y:y+h, x:x+w]  # Crop face

    # Debugging: Log face coordinates
    print(f"Face coordinates: x={x}, y={y}, w={w}, h={h}")

    return face, None

# Preprocess the image for the model
def preprocess_image(face):
    try:
        # Convert to grayscale
        gray_face = cv2.cvtColor(face, cv2.COLOR_BGR2GRAY)
        
        # Resize the image to 48x48 (size expected by model)
        resized_face = cv2.resize(gray_face, (48, 48))
        
        # Normalize and expand dimensions (model expects 4D input)
        resized_face = resized_face / 255.0  # Normalize to [0, 1]
        resized_face = np.expand_dims(resized_face, axis=-1)  # Add channel dimension (grayscale)
        resized_face = np.expand_dims(resized_face, axis=0)  # Add batch dimension

        return resized_face.astype(np.float32)
    except Exception as e:
        raise ValueError(f"Error processing image: {e}")

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image file'}), 400

    file = request.files['image']
    
    # Validate image format
    if file.mimetype not in ['image/jpeg', 'image/png']:
        return jsonify({'error': 'Invalid image format. Only JPEG and PNG are allowed.'}), 400

    try:
        image_bytes = file.read()
        
        # Detect and crop face
        face, error = detect_and_crop_face(image_bytes)
        if error:
            # If no face detected, return error message
            return jsonify({'error': error}), 400
        
        # Preprocess the cropped face image
        processed_image = preprocess_image(face)
        
        # Predict with the model
        prediction = model.predict(processed_image)[0]

        # Define the labels corresponding to the 7 classes
        labels = ['angry', 'disgusted', 'fearful', 'happy', 'neutral', 'sad', 'surprised']

        # Map classes to 4 moods
        mood_mapping = {
            'happy': ['happy', 'surprised'],
            'sad': ['sad', 'disgusted'],
            'neutral': ['neutral'],
            'angry': ['angry', 'fearful']
        }

        predicted_class_index = np.argmax(prediction)
        predicted_class = labels[predicted_class_index]
        predicted_mood = next((mood for mood, classes in mood_mapping.items() if predicted_class in classes), 'unknown')

        # Calculate confidence as percentage
        confidence = prediction[predicted_class_index] * 100

        # Log the prediction and confidence
        print(f"Predicted Mood: {predicted_mood}")
        print(f"Confidence: {confidence:.2f}%")

        return jsonify({'predicted_mood': predicted_mood, 'confidence': f"{confidence:.2f}%"})

    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': 'Internal server error', 'message': str(e)}), 500

if __name__ == '__main__': 
    app.run(host='0.0.0.0', port=5000)
