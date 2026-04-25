import { useState, useEffect } from 'react'
import { collection, onSnapshot, doc, updateDoc } from 'firebase/firestore'
import { db } from '../config/firebase'

/**
 * Custom hook for real-time hospital data with admin editing capabilities.
 * Uses onSnapshot listener for instant UI updates.
 */
export function useHospitals() {
  const [hospitals, setHospitals] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const unsubscribe = onSnapshot(
      collection(db, 'hospital'),
      (snapshot) => {
        const data = snapshot.docs.map((d) => ({
          id: d.id,
          ...d.data(),
        }))
        setHospitals(data)
        setLoading(false)
      },
      (error) => {
        console.error('Hospital listener error:', error)
        setLoading(false)
      }
    )

    return () => unsubscribe()
  }, [])

  /**
   * Update a hospital document in Firestore.
   * @param {string} hospitalId - Document ID
   * @param {object} updates - Fields to update (availableBeds, ICUAvailable, status)
   */
  const updateHospital = async (hospitalId, updates) => {
    try {
      await updateDoc(doc(db, 'hospital', hospitalId), updates)
      return true
    } catch (error) {
      console.error('Error updating hospital:', error)
      return false
    }
  }

  return { hospitals, loading, updateHospital }
}
