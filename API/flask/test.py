# import tensorflow as tf
# import numpy as np

# # Path to your Keras (.h5) model
# MODEL_PATH = "../models/emotion_model.weights.h5"  # Change this if needed

# def inspect_model(model_path):
#     try:
#         # Load Keras model
#         model = tf.keras.models.load_model(model_path)

#         print("==== Model Information ====")

#         # Input shape
#         input_shape = model.input_shape
#         print(f"Input Shape: {input_shape}")

#         # Output shape
#         output_shape = model.output_shape
#         print(f"Output Shape: {output_shape}")

#         # Check number of output classes
#         num_classes = output_shape[-1]
#         print("\n==== Prediction Class Check ====")
#         print(f"Model Outputs {num_classes} Classes")

#         # Check if number of classes matches your label list
#         expected_labels = ['happy', 'sad', 'neutral', 'angry', 'surprised', 'disgusted', 'fearful']
#         if num_classes == len(expected_labels):
#             print("✅ Model output matches expected labels.")
#         else:
#             print(f"⚠️ Mismatch! Model has {num_classes} outputs but expected {len(expected_labels)}.")
#     except Exception as e:
#         print(f"Error inspecting model: {e}")

# if __name__ == "__main__":
#     inspect_model(MODEL_PATH)


# import h5py

# weights_path = "../models/emotionModelWeights.h5"
# with h5py.File(weights_path, 'r') as f:
#     print(f.keys())  # Should show layer names
#     model.summary()

# from tensorflow.keras.models import model_from_json

# # Load model architecture from JSON
# with open("../models/jsonfile.json", "r") as json_file:
#     model_json = json_file.read()
# model = model_from_json(model_json)

# # Load weights from H5 file
# model.load_weights("../models/emotion_model.weights.h5")

# # Print model summary
# model.summary()


# from tensorflow.keras.models import load_model

# # Load your trained model
# model = load_model("../models/emotion_model.weights.h5")

# # Get the last layer (output layer)
# output_layer = model.layers[-1]

# # Print number of output classes
# num_classes = output_layer.output_shape[-1]
# print(f"Number of output classes: {num_classes}")


from tensorflow.keras.models import model_from_json

# Load the model architecture
with open("../models/jsonfile.json", "r") as json_file:
    model_json = json_file.read()

model = model_from_json(model_json)  # Create model from JSON

# Load weights into the model
model.load_weights("../models/emotion_model.weights.h5")

print("Model loaded successfully!")

import numpy as np

# Assuming you used categorical_crossentropy during training
num_classes = model.output_shape[-1]  # Get number of output classes
print(f"Number of classes: {num_classes}")

# If you had a label mapping during training, use it
emotion_labels = ["Angry", "Disgust", "Fear", "Happy", "Neutral", "Sad", "Surprise"]  # Example labels
print(f"Emotion Labels: {emotion_labels[:num_classes]}")

