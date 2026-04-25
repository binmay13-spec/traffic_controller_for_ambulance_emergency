import React, { useMemo } from 'react'

/**
 * Calculates distance between two GPS coordinates using Haversine formula.
 * @returns Distance in kilometers.
 */
function calcDistance(lat1, lon1, lat2, lon2) {
  if (!lat1 || !lon1 || !lat2 || !lon2) return 0
  const R = 6371 // Earth's radius in km
  const dLat = ((lat2 - lat1) * Math.PI) / 180
  const dLon = ((lon2 - lon1) * Math.PI) / 180
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  return R * c
}

function InfoPanel({ activeAmbulance, hospitals }) {
  const isActive = activeAmbulance?.status === 'ACTIVE'

  // Find destination hospital
  const destHospital = useMemo(() => {
    if (!activeAmbulance?.destinationHospital) return null
    return hospitals.find((h) => h.id === activeAmbulance.destinationHospital)
  }, [activeAmbulance?.destinationHospital, hospitals])

  // Calculate distance remaining
  const distance = useMemo(() => {
    if (!isActive || !destHospital || !activeAmbulance?.latitude) return 0
    return calcDistance(
      activeAmbulance.latitude,
      activeAmbulance.longitude,
      destHospital.location?.lat,
      destHospital.location?.lon
    )
  }, [
    isActive,
    activeAmbulance?.latitude,
    activeAmbulance?.longitude,
    destHospital,
  ])

  // Calculate ETA
  const eta = useMemo(() => {
    const speed = activeAmbulance?.speed || 0
    if (distance <= 0) return 0
    if (speed > 2) {
      return (distance / speed) * 60 // minutes
    }
    return (distance / 40) * 60 // Assume 40 km/h when stationary
  }, [distance, activeAmbulance?.speed])

  return (
    <div className="info-panel">
      <h3 className="info-panel-title">Ambulance Status</h3>

      {/* Status Card */}
      <div className="info-card">
        <div className="card-header">
          <span className="card-label">Current Status</span>
          <span className={`status-badge ${isActive ? 'active' : 'inactive'}`}>
            <span className="status-dot"></span>
            {isActive ? 'ACTIVE' : 'INACTIVE'}
          </span>
        </div>

        {isActive ? (
          <div className="info-grid">
            <div className="info-item speed">
              <div className="info-icon">⚡</div>
              <div className="info-value">
                {(activeAmbulance?.speed || 0).toFixed(1)}
              </div>
              <div className="info-label">km/h</div>
            </div>

            <div className="info-item distance">
              <div className="info-icon">📍</div>
              <div className="info-value">{distance.toFixed(1)}</div>
              <div className="info-label">km remaining</div>
            </div>

            <div className="info-item eta">
              <div className="info-icon">⏱️</div>
              <div className="info-value">{Math.ceil(eta)}</div>
              <div className="info-label">min ETA</div>
            </div>

            <div className="info-item destination">
              <div className="info-icon">🏥</div>
              <div className="info-value">
                {destHospital?.name || 'Unknown'}
              </div>
              <div className="info-label">Destination</div>
            </div>
          </div>
        ) : (
          <div
            style={{
              textAlign: 'center',
              padding: '20px 0',
              color: 'var(--text-muted)',
              fontSize: '14px',
            }}
          >
            No active emergency at this time.
            <br />
            <span style={{ fontSize: '12px', opacity: 0.7 }}>
              Ambulance data will appear here during emergencies.
            </span>
          </div>
        )}
      </div>

      {/* Coordinates Card (when active) */}
      {isActive && activeAmbulance?.latitude ? (
        <div className="info-card fade-in">
          <div className="card-header">
            <span className="card-label">Live Coordinates</span>
          </div>
          <div
            style={{
              fontFamily: "'Courier New', monospace",
              fontSize: '13px',
              color: 'var(--text-secondary)',
              lineHeight: '1.8',
            }}
          >
            <div>
              LAT:{' '}
              <span className="text-green">
                {activeAmbulance.latitude.toFixed(6)}
              </span>
            </div>
            <div>
              LNG:{' '}
              <span className="text-blue">
                {activeAmbulance.longitude.toFixed(6)}
              </span>
            </div>
            <div>
              SPD:{' '}
              <span className="text-amber">
                {(activeAmbulance.speed || 0).toFixed(1)} km/h
              </span>
            </div>
          </div>
        </div>
      ) : null}
    </div>
  )
}

export default InfoPanel
