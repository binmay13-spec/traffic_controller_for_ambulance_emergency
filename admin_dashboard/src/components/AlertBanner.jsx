import React from 'react'

function AlertBanner({ activeAmbulance, hospitals }) {
  if (!activeAmbulance || activeAmbulance.status !== 'ACTIVE') {
    return null
  }

  // Find destination hospital name
  const destHospital = hospitals.find(
    (h) => h.id === activeAmbulance.destinationHospital
  )
  const hospitalName = destHospital?.name || 'Unknown Hospital'

  return (
    <div className="alert-banner" id="emergency-alert">
      <span className="alert-icon">🚨</span>
      <span className="alert-dot"></span>
      <span className="alert-text">
        Ambulance en route to <strong>{hospitalName}</strong> — Prepare emergency ward immediately
      </span>
      <span className="alert-dot"></span>
      <span className="alert-icon">🚨</span>
    </div>
  )
}

export default AlertBanner
