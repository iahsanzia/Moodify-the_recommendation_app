from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import base64

app = Flask(__name__)
CORS(app)

# TMDb access token
TMDB_ACCESS_TOKEN = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI2OGQ2NmY3ZDBiY2MyYTBkNWZmOWNiZTFmZGEwODYyYiIsIm5iZiI6MTc0NDgzMzcxNC43NDcsInN1YiI6IjY4MDAwY2IyZDY0NWU0MWUwOTk5N2I1OCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.FvfgPI5HQTizRZGO6uYmAsar55uCXVjC9aP-_jtZqrg"

# Spotify credentials
SPOTIFY_CLIENT_ID = "48e6deb17519400ca5d360fcd1a7cc94"
SPOTIFY_CLIENT_SECRET = "7326b3d2f17a4c0f99798a455f69c288"
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

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=3000)