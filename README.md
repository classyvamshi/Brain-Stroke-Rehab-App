Reneuw: An AI-Powered Brain Stroke Rehabilitation Application
A Flutter-based Mobile Health (mHealth) Application for Stroke Rehabilitation



##📌 Introduction
Reneuw – Rewiring Minds, Restoring Lives – is a cross-platform mobile health (mHealth) application developed using Flutter, designed to empower stroke survivors with comprehensive cognitive, physical, emotional, and lifestyle rehabilitation tools. Available for both Android and iOS, Reneuw integrates advanced AI technologies, including a voice-enabled chatbot, MRI-based stroke prediction, and gamified cognitive exercises, to provide personalized, home-based care.
Key Features:

Health Monitoring: Tracks daily water intake, meal nutrients (calories, carbs, proteins, fats, sugars, cholesterol), and body measurements (BMI, BMR, caloric needs).
Cognitive Training: Includes games like Chess, Snakes and Ladders, and Memory Match to enhance mental agility.
Emotional Wellness: Offers depression risk self-assessment and guided meditation/yoga routines.
AI-Powered Chatbot: Supports text and voice queries using LangChain and Gemini 1.5 for speech-to-text, aiding users with speech impairments.
Stroke Prediction: Utilizes a fine-tuned VGG-19 model to classify ischemic and hemorrhagic strokes from MRI scans with 94% accuracy.
News Feed: Fetches daily health articles via a News API to promote cognitive engagement.

Reneuw leverages a FastAPI backend and MongoDB Atlas for scalable data management, ensuring secure, real-time health tracking and a seamless user experience.
🏁 Tech Stack Used

Flutter: Cross-platform mobile app development.
FastAPI: High-performance backend API framework.
MongoDB Atlas: Cloud-based NoSQL database.
Firebase: Secure user authentication (email and Google Sign-In).
LangChain: Orchestrates large language model interactions for the chatbot.
TensorFlow/Keras: Powers the VGG-19 model for stroke prediction.

📦 APIs Used

Gemini 1.5 API: Speech-to-text conversion for the chatbot.
News API: Daily health and rehabilitation articles.
Pre-trained VGG-19 Model: Fine-tuned for MRI-based stroke classification.

🏃‍♂️ Getting Started
These instructions will help you set up and run Reneuw on your local machine for development and testing.
📋 Prerequisites

Flutter SDK with a recent version.
Android Studio or Xcode for Android/iOS emulation.
Git for repository cloning.
Python for the FastAPI backend.
MongoDB Atlas and Firebase accounts for database and authentication.

🧱 Setting Up Your Development Environment

Install Git:

Download and install Git.


Fork the Repository:

Fork the Reneuw project on GitHub.


Clone the Repository:
git clone https://github.com/YOUR-USERNAME/Reneuw.git


Open the Project:

Open your preferred IDE (VS Code, Android Studio, etc.).
Select "Open an Existing Project" and navigate to the cloned Reneuw directory.


Set Up Firebase:

Create a Firebase project at console.firebase.google.com.
Add an Android/iOS app and download google-services.json (Android) or GoogleService-Info.plist (iOS).
Place these files in android/app/ (Android) or ios/Runner/ (iOS).
Enable Email/Password and Google Sign-In in Firebase Authentication.


Configure the Backend:

Navigate to the backend directory (e.g., backend/).
Install Python dependencies:pip install -r requirements.txt


Create a .env file in the backend directory:MONGODB_URI=your_mongodb_atlas_connection_string
GEMINI_API_KEY=your_gemini_api_key
NEWS_API_KEY=your_news_api_key


Start the FastAPI server:uvicorn main:app --reload




Install Flutter Dependencies:

In the project root, run:flutter pub get




Run the Application:

Connect an Android/iOS emulator or physical device.
Click the Run  button in your IDE or use:flutter run





👀 Application Preview











📝 Why This Project?
Stroke is a leading cause of long-term disability globally, affecting millions each year. Survivors often require extensive rehabilitation to regain cognitive, physical, and emotional function, but traditional clinical care is frequently inaccessible due to logistical, financial, or geographical constraints. Existing mobile health solutions lack the comprehensive, integrated approach needed for effective post-stroke recovery, particularly for users with speech or motor impairments.
Reneuw addresses these gaps by offering an all-in-one platform that empowers stroke survivors to manage their rehabilitation from home. By combining health tracking, cognitive exercises, mental wellness tools, and AI-driven diagnostics, it provides a holistic, user-centric solution. The app’s accessibility features, like voice-enabled interaction, cater to diverse needs, while its scalable architecture supports future enhancements like teleconsultation and wearable integration.
🏃‍♂️ How We Came to Solve This Problem?
Recognizing the challenges of post-stroke recovery, we developed Reneuw to deliver personalized, inclusive, and technology-driven rehabilitation:

Comprehensive Care: Tracks hydration, nutrition, and body metrics to manage stroke risk factors, while cognitive games and news articles stimulate mental engagement.
Inclusivity: The AI chatbot’s voice-to-text functionality supports users with speech impairments, and the intuitive Flutter UI is designed for elderly or motor-impaired users.
Early Detection: The VGG-19 model’s 94% accurate stroke classification from MRI scans enables timely interventions, especially in underserved areas.
Emotional Support: Depression risk assessments and guided meditation/yoga promote mental wellness, addressing isolation and stress.
Scalable Infrastructure: FastAPI and MongoDB ensure secure, real-time data management, enabling longitudinal health tracking and personalized recommendations.

Reneuw integrates these features into a single, seamless app, reducing the need for multiple tools and fostering consistent engagement in the recovery process.
🛠 Try It Out
Try Reneuw live on Appetize.io (update with actual link once hosted).
🎓 Resources
New to Flutter or backend development? Start here:

Lab: Write Your First Flutter App
Cookbook: Useful Flutter Samples
Flutter Documentation: Tutorials, samples, and API references
FastAPI Documentation
MongoDB Atlas Getting Started

✨ Team Reneuw
Thanks to these wonderful contributors (emoji key):


    Alajangi Venkata Satya💻 📖 🤔 
    K N Lakshmi💻 📖 🤔
    K Hemavardhan Reddy💻 📖 🤔
    K V Vamshidhar Reddy💻 📖 🤔
    DR. Keerthika T🧑‍🏫 🤔
  


📜 License
This project is licensed under the MIT License – see the LICENSE file for details.
🙌 Contributing
We welcome contributions! Please read our Contributing Guidelines and submit pull requests to enhance Reneuw’s features or fix issues.

Built with 💙 by Team Reneuw at Amrita School of Artificial Intelligence, Amrita Vishwa Vidyapeetham.
