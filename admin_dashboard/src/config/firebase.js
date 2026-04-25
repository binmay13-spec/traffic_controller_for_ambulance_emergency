import { initializeApp } from 'firebase/app'
import { getAuth } from 'firebase/auth'
import { getFirestore } from 'firebase/firestore'

const firebaseConfig = {
  apiKey: "AIzaSyBLGDgL90oGNF9HBddvRe7fOGLaZ6koQuM",
  authDomain: "tcma-9cb49.firebaseapp.com",
  projectId: "tcma-9cb49",
  storageBucket: "tcma-9cb49.firebasestorage.app",
  messagingSenderId: "407007548695",
  appId: "1:407007548695:web:9055871435d14598805352",
  measurementId: "G-G31XB9PSXP"
}

const app = initializeApp(firebaseConfig)
export const auth = getAuth(app)
export const db = getFirestore(app)
export default app
