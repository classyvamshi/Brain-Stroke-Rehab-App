Reneuw: An AI-Powered Brain Stroke Rehabilitation Application
A Flutter-based Mobile Health (mHealth) Application for Stroke Rehabilitation
📌 Introduction
Reneuw – Rewiring Minds, Restoring Lives – is a cross-platform mobile health (mHealth) application built using Flutter, designed to support stroke survivors in their cognitive, physical, emotional, and lifestyle rehabilitation. Deployable on both Android and iOS, Reneuw offers a comprehensive ecosystem with features like health tracking, cognitive games, a voice-enabled AI chatbot, guided meditation, and MRI-based stroke prediction. Powered by a FastAPI backend and MongoDB Atlas for scalable data storage, it integrates cutting-edge AI technologies to provide personalized, home-based care for post-stroke recovery.
Key features include:

Health Monitoring: Tracks water intake, meal nutrients, and body measurements (BMI, BMR, caloric needs).
Cognitive Training: Offers games like Chess, Snakes and Ladders, and Memory Match.
Mental Wellness: Includes self-assessment for depression risk and guided meditation/yoga routines.
AI Chatbot: Supports text and voice interaction using LangChain and Gemini 1.5 for speech-to-text.
Stroke Prediction: Uses a VGG-19 deep learning model to classify ischemic and hemorrhagic strokes from MRI scans with 94% accuracy.
News Feed: Delivers daily articles via a News API to promote cognitive engagement.

Reneuw aims to bridge the gap between clinical rehabilitation and home-based care, empowering stroke survivors with an accessible, scalable, and user-centric digital health solution.
🏁 Tech Stack Used

Flutter: For cross-platform mobile app development.
FastAPI: For high-performance backend API services.
MongoDB Atlas: For scalable, cloud-based NoSQL data storage.
Firebase: For secure user authentication (email and Google Sign-In).
LangChain: For orchestrating the AI chatbot’s large language model interactions.
TensorFlow/Keras: For the VGG-19 deep learning model used in stroke prediction.

📦 APIs and Services Used

Gemini 1.5 API: For speech-to-text conversion in the AI chatbot.
News API: For fetching daily health and rehabilitation-related articles.
Pre-trained VGG-19 Model: Fine-tuned for MRI-based stroke classification.

🏃‍♂️ Getting Started
Follow these instructions to set up and run Reneuw on your local machine for development and testing.
📋 Prerequisites

Flutter SDK: Ensure Flutter is installed and configured.
Android Studio or Xcode: For Android/iOS emulation or physical device testing.
Git: For cloning the repository.
Python: For running the FastAPI backend.
A MongoDB Atlas account and Firebase project for backend and authentication setup.

🧱 Setting Up Your Development Environment

Clone the Repository:
git clone https://github.com/YOUR-USERNAME/Reneuw.git

Replace YOUR-USERNAME with your GitHub username or the repository URL.

Set Up the Flutter Frontend:

Open the cloned project in your preferred IDE (e.g., VS Code, Android Studio).

Navigate to the project root and install dependencies:
flutter pub get




Configure Firebase:

Create a Firebase project at console.firebase.google.com.
Add an Android/iOS app to your Firebase project and download the google-services.json (Android) or GoogleService-Info.plist (iOS) file.
Place these files in the appropriate directories (android/app/ for Android, ios/Runner/ for iOS).
Enable Firebase Authentication (Email/Password and Google Sign-In) in the Firebase console.


Set Up the FastAPI Backend:

Navigate to the backend directory (e.g., backend/ if included in the repo).

Install Python dependencies:
pip install -r requirements.txt


Create a .env file in the backend directory with the following variables:
MONGODB_URI=your_mongodb_atlas_connection_string
GEMINI_API_KEY=your_gemini_api_key
NEWS_API_KEY=your_news_api_key


Run the FastAPI server:
uvicorn main:app --reload




Configure MongoDB Atlas:

Set up a MongoDB Atlas cluster and obtain the connection URI.
Update the .env file with the MongoDB URI.


Run the Application:

Connect an Android/iOS emulator or physical device.

Build and run the Flutter app:
flutter run


Alternatively, use the Run button in your IDE.




👀 Application Preview
Note: Replace README_Images/ with the actual path to your image assets once created.
📝 Why This Project?
Stroke remains a leading cause of long-term disability worldwide, affecting millions annually. Survivors often face prolonged recovery requiring sustained cognitive, physical, and emotional rehabilitation, which is typically confined to clinical settings. These settings can be inaccessible due to logistical, financial, or geographical barriers, leaving many patients without adequate support. The rise of mobile health (mHealth) solutions offers a promising avenue for home-based, personalized care, yet existing apps often lack comprehensive, integrated features tailored for stroke rehabilitation.
Reneuw addresses these challenges by providing an all-in-one platform that empowers stroke survivors to manage their recovery from home. It combines health tracking, cognitive exercises, mental wellness tools, and AI-driven diagnostics to create a holistic rehabilitation ecosystem. Features like the voice-enabled chatbot cater to users with speech impairments, while the MRI-based stroke prediction module enables early detection, particularly in underserved areas. By leveraging modern technologies, Reneuw aims to democratize access to quality rehabilitation and improve patient outcomes.
🏃‍♂️ How We Solved This Problem
Reneuw was designed with a user-centric approach to address the multifaceted needs of stroke survivors:

Physical Health: Tracks hydration, nutrition, and body metrics to promote healthy lifestyles and manage stroke risk factors like obesity and hypertension.
Cognitive Rehabilitation: Offers gamified exercises (e.g., Memory Match, Chess) to combat post-stroke cognitive decline and enhance mental agility.
Emotional Wellness: Includes depression risk assessments and guided meditation/yoga to support mental health, reducing isolation and stress.
Accessibility: The AI chatbot’s voice-to-text feature ensures inclusivity for users with speech or motor impairments, while the intuitive Flutter UI caters to elderly users.
Predictive Diagnostics: The VGG-19 model provides 94% accurate stroke classification from MRI scans, enabling timely interventions in areas with limited access to specialists.
Scalable Data Management: MongoDB Atlas and FastAPI ensure secure, real-time data storage and retrieval, supporting longitudinal health monitoring.

By integrating these features into a single app, Reneuw eliminates the need for multiple tools, offering a seamless, engaging, and effective rehabilitation experience.
🛠 Try It Out
You can try a live demo of Reneuw on Appetize.io (update with actual link once hosted) or build it locally using the setup instructions above.
🎓 Resources
New to Flutter? Here are some resources to get started:

Write Your First Flutter App
Flutter Cookbook: Useful Samples
Flutter Documentation: Tutorials, samples, and API references.

For backend development:

FastAPI Documentation
MongoDB Atlas Getting Started

✨ Team Reneuw

K N Lakshmi
Alajangi Venkata Satya
K Hemavardhan Reddy
K V Vamshidhar Reddy
DR. Keerthika T

📜 License
This project is licensed under the MIT License – see the LICENSE file for details.
🙌 Contributing
We welcome contributions! Please read our Contributing Guidelines and submit pull requests to enhance Reneuw’s features or fix issues.

Built with 💙 by Team Reneuw at Amrita School of Artificial Intelligence, Amrita Vishwa Vidyapeetham.
