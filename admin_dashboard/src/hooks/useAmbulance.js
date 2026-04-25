import { useState, useEffect } from 'react'
import { collection, onSnapshot } from 'firebase/firestore'
import { db } from '../config/firebase'

/**
 * Custom hook for real-time ambulance data from Firestore.
 * Uses onSnapshot listener for instant UI updates.
 */
export function useAmbulance() {
  const [ambulances, setAmbulances] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const unsubscribe = onSnapshot(
      collection(db, 'ambulance'),
      (snapshot) => {
        const data = snapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
        }))
        setAmbulances(data)
        setLoading(false)
      },
      (error) => {
        console.error('Ambulance listener error:', error)
        setLoading(false)
      }
    )

    return () => unsubscribe()
  }, [])

  // Find the first active ambulance (primary use case)
  const activeAmbulance = ambulances.find((a) => a.status === 'ACTIVE') || null

  return { ambulances, activeAmbulance, loading }
}
