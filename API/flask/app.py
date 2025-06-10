from flask import Flask, request, jsonify
import tensorflow as tf
import numpy as np
import json
from tensorflow.keras.models import model_from_json
from PIL import Image
import io
import cv2
from mtcnn import MTCNN
from flask_cors import CORS
import requests
import base64
import os
from dotenv import load_dotenv

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

# Load environment variables from backend/.env
load_dotenv(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../backend/.env'))
CORS(app)

# TMDb access token
TMDB_ACCESS_TOKEN = os.getenv("TMDB_ACCESS_TOKEN")

# Spotify credentials
SPOTIFY_CLIENT_ID = os.getenv("SPOTIFY_CLIENT_ID")
SPOTIFY_CLIENT_SECRET = os.getenv("SPOTIFY_CLIENT_SECRET")
SPOTIFY_ACCESS_TOKEN = None

def get_spotify_token():
    global SPOTIFY_ACCESS_TOKEN
    auth_str = f"{SPOTIFY_CLIENT_ID}:{SPOTIFY_CLIENT_SECRET}"
    b64_auth = base64.b64encode(auth_str.encode()).decode()

    response = requests.post(
        "https://accounts.spotify.com/api/token",
        headers={
            "Authorization": f"Basic {b64_auth}",
            "Content-Type": "application/x-www-form-urlencoded"
        },
        data={"grant_type": "client_credentials"}
    )
    if response.status_code == 200:
        SPOTIFY_ACCESS_TOKEN = response.json()['access_token']
    else:
        print("Spotify token error:", response.text)

@app.route("/search", methods=["POST"])
def search_all():
    data = request.get_json()
    query = data.get("query", "")
    search_type = data.get("type", "").lower()

    if search_type in ["actor", "actress", "director"]:
        url = f"https://api.themoviedb.org/3/search/person?query={query}"
        headers = {"Authorization": f"Bearer {TMDB_ACCESS_TOKEN}"}
        res = requests.get(url, headers=headers)
        if res.status_code == 200:
            results = res.json()
            names = [person["name"] for person in results.get("results", [])]
            return jsonify({"results": names})
        else:
            return jsonify({"error": "TMDb API failed"}), 500

    elif search_type == "singer":
        if not SPOTIFY_ACCESS_TOKEN:
            get_spotify_token()
        headers = {"Authorization": f"Bearer {SPOTIFY_ACCESS_TOKEN}"}
        url = f"https://api.spotify.com/v1/search?q={query}&type=artist"
        res = requests.get(url, headers=headers)
        if res.status_code == 200:
            results = res.json()
            names = [artist["name"] for artist in results.get("artists", {}).get("items", [])]
            return jsonify({"results": names})
        else:
            return jsonify({"error": "Spotify API failed"}), 500

    else:
        return jsonify({"error": "Invalid search type"}), 400

@app.route("/recommendation", methods=["POST"])
def get_recommendations():
    global SPOTIFY_ACCESS_TOKEN

    data = request.get_json()
    mood = data.get("mood", "neutral")
    music_genre = data.get("musicGenre", "Pop")
    movie_genre = data.get("movieGenre", "Action")
    language = data.get("language", "en")
    era = data.get("era", "2020s")
    actors = data.get("actors", [])
    actress = data.get("actress", [])
    directors = data.get("directors", [])
    singers = data.get("singers", [])

    # ---------------- MOVIE FETCHING ----------------
    movie_results = []
    try:
        headers = {"Authorization": f"Bearer {TMDB_ACCESS_TOKEN}"}
        seen_titles = set()
        prioritized_movies = []

        people = actors + actress + directors
        for person in people:
            search_res = requests.get(
                f"https://api.themoviedb.org/3/search/person",
                params={"query": person},
                headers=headers
            )
            if search_res.status_code == 200:
                res_data = search_res.json().get("results", [])
                if res_data:
                    person_id = res_data[0]["id"]
                    credits = requests.get(
                        f"https://api.themoviedb.org/3/person/{person_id}/movie_credits",
                        headers=headers
                    )
                    if credits.status_code == 200:
                        all_movies = credits.json().get("cast", []) + credits.json().get("crew", [])
                        for m in all_movies:
                            title = m.get("title")
                            if title and title not in seen_titles:
                                prioritized_movies.append(m)
                                seen_titles.add(title)
                            if len(prioritized_movies) >= 5:
                                break

        start_year = era[:4] if era and len(era) == 5 else "2020"
        end_year = str(int(start_year) + 9)
        start_date = f"{start_year}-01-01"
        end_date = f"{end_year}-12-31"

        discover_res = requests.get(
            "https://api.themoviedb.org/3/discover/movie",
            headers=headers,
            params={
                "language": language,
                "sort_by": "vote_average.desc",
                "vote_average.gte": 6.5,
                "vote_count.gte": 50,
                "primary_release_date.gte": start_date,
                "primary_release_date.lte": end_date,
                "with_keywords": movie_genre
            }
        )
        general_movies = discover_res.json().get("results", []) if discover_res.status_code == 200 else []

        movie_results = prioritized_movies + [m for m in general_movies if m.get("title") not in seen_titles]
        movie_results = movie_results[:10]

    except Exception as e:
        print("Movie fetch error:", str(e))

    # ---------------- MUSIC FETCHING ----------------
    song_results = []
    try:
        if not SPOTIFY_ACCESS_TOKEN:
            get_spotify_token()

        headers = {"Authorization": f"Bearer {SPOTIFY_ACCESS_TOKEN}"}
        seen_tracks = set()
        prioritized_tracks = []

        for singer in singers:
            search = requests.get(
                "https://api.spotify.com/v1/search",
                headers=headers,
                params={"q": singer, "type": "artist", "limit": 1}
            )
            artist_items = search.json().get("artists", {}).get("items", []) if search.status_code == 200 else []
            if artist_items:
                artist_id = artist_items[0]["id"]
                top_tracks = requests.get(
                    f"https://api.spotify.com/v1/artists/{artist_id}/top-tracks",
                    headers=headers,
                    params={"market": "US"}
                )
                if top_tracks.status_code == 200:
                    for t in top_tracks.json().get("tracks", []):
                        key = (t["name"], t["artists"][0]["name"])
                        if key not in seen_tracks:
                            prioritized_tracks.append({
                                "name": t["name"],
                                "artist": ", ".join([a["name"] for a in t["artists"]]),
                                "url": t["external_urls"]["spotify"],
                                "image": t["album"]["images"][0]["url"] if t["album"]["images"] else None
                            })
                            seen_tracks.add(key)
                        if len(prioritized_tracks) >= 5:
                            break

        fallback = requests.get(
            "https://api.spotify.com/v1/search",
            headers=headers,
            params={"q": f"genre:{music_genre}", "type": "track", "limit": 10}
        )
        general_tracks = []
        if fallback.status_code == 200:
            for item in fallback.json().get("tracks", {}).get("items", []):
                key = (item["name"], item["artists"][0]["name"])
                if key not in seen_tracks:
                    general_tracks.append({
                        "name": item["name"],
                        "artist": ", ".join([a["name"] for a in item["artists"]]),
                        "url": item["external_urls"]["spotify"],
                        "image": item["album"]["images"][0]["url"] if item["album"]["images"] else None
                    })
                    seen_tracks.add(key)

        song_results = prioritized_tracks + general_tracks
        song_results = song_results[:10]

    except Exception as e:
        print("Spotify fetch error:", str(e))

    return jsonify({
        "mood": mood,
        "recommendedMovies": movie_results,
        "recommendedSongs": song_results
    })

if __name__ == '__main__': 
    app.run(host='0.0.0.0', port=5000)
