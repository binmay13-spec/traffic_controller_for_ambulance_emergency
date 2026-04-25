import React, { useCallback, useRef, useEffect, useState } from 'react'
import { GoogleMap, useJsApiLoader, Marker, Polyline } from '@react-google-maps/api'

// ─── IMPORTANT: Replace with your Google Maps API key ───────────
const GOOGLE_MAPS_API_KEY = 'YOUR_GOOGLE_MAPS_API_KEY'

const mapContainerStyle = {
  width: '100%',
  height: '100%',
}

// Default center (India)
const defaultCenter = { lat: 20.5937, lng: 78.9629 }

// Dark-mode map styles
const darkMapStyles = [
  { elementType: 'geometry', stylers: [{ color: '#1d2c4d' }] },
  { elementType: 'labels.text.fill', stylers: [{ color: '#8ec3b9' }] },
  { elementType: 'labels.text.stroke', stylers: [{ color: '#1a3646' }] },
  { featureType: 'administrative.country', elementType: 'geometry.stroke', stylers: [{ color: '#4b6878' }] },
  { featureType: 'land', elementType: 'geometry', stylers: [{ color: '#0e1626' }] },
  { featureType: 'poi', elementType: 'geometry', stylers: [{ color: '#283d6a' }] },
  { featureType: 'poi', elementType: 'labels.text.fill', stylers: [{ color: '#6f9ba5' }] },
  { featureType: 'road', elementType: 'geometry', stylers: [{ color: '#304a7d' }] },
  { featureType: 'road', elementType: 'geometry.stroke', stylers: [{ color: '#255779' }] },
  { featureType: 'road.highway', elementType: 'geometry', stylers: [{ color: '#2c6675' }] },
  { featureType: 'road.highway', elementType: 'geometry.stroke', stylers: [{ color: '#255763' }] },
  { featureType: 'transit', elementType: 'labels.text.fill', stylers: [{ color: '#98a5be' }] },
  { featureType: 'water', elementType: 'geometry', stylers: [{ color: '#0e1626' }] },
  { featureType: 'water', elementType: 'labels.text.fill', stylers: [{ color: '#4e6d70' }] },
]

function LiveMap({ activeAmbulance, hospitals }) {
  const mapRef = useRef(null)
  const [mapCenter, setMapCenter] = useState(defaultCenter)

  const { isLoaded, loadError } = useJsApiLoader({
    googleMapsApiKey: GOOGLE_MAPS_API_KEY,
  })

  // Update map center when ambulance position changes
  useEffect(() => {
    if (activeAmbulance?.latitude && activeAmbulance?.longitude) {
      const newCenter = {
        lat: activeAmbulance.latitude,
        lng: activeAmbulance.longitude,
      }
      setMapCenter(newCenter)
      if (mapRef.current) {
        mapRef.current.panTo(newCenter)
      }
    }
  }, [activeAmbulance?.latitude, activeAmbulance?.longitude])

  const onMapLoad = useCallback((map) => {
    mapRef.current = map
  }, [])

  // Build path from ambulance to destination
  const pathCoords = React.useMemo(() => {
    if (!activeAmbulance?.latitude || !activeAmbulance.destinationHospital) return []

    const destHospital = hospitals.find(
      (h) => h.id === activeAmbulance.destinationHospital
    )
    if (!destHospital?.location) return []

    return [
      { lat: activeAmbulance.latitude, lng: activeAmbulance.longitude },
      { lat: destHospital.location.lat, lng: destHospital.location.lon },
    ]
  }, [activeAmbulance, hospitals])

  // If Google Maps API key is not set, show placeholder
  if (GOOGLE_MAPS_API_KEY === 'YOUR_GOOGLE_MAPS_API_KEY') {
    return (
      <div className="live-map">
        <div className="map-placeholder">
          <div className="map-icon">🗺️</div>
          <p>Google Maps API Key Required</p>
          <p style={{ fontSize: '12px', color: 'var(--text-muted)', maxWidth: '300px', textAlign: 'center' }}>
            Replace <code>YOUR_GOOGLE_MAPS_API_KEY</code> in <code>LiveMap.jsx</code> with your actual Google Maps API key to enable the live map.
          </p>

          {/* Show ambulance position data even without map */}
          {activeAmbulance?.status === 'ACTIVE' && (
            <div className="map-overlay-info" style={{ position: 'relative', top: 'auto', left: 'auto', marginTop: '20px' }}>
              <span style={{ fontSize: '20px' }}>🚑</span>
              <div>
                <div className="coord">
                  LAT: {activeAmbulance.latitude?.toFixed(6) || '—'}
                </div>
                <div className="coord">
                  LNG: {activeAmbulance.longitude?.toFixed(6) || '—'}
                </div>
                <div className="coord" style={{ color: 'var(--available-green)' }}>
                  SPD: {(activeAmbulance.speed || 0).toFixed(1)} km/h
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    )
  }

  if (loadError) {
    return (
      <div className="live-map">
        <div className="map-placeholder">
          <div className="map-icon">⚠️</div>
          <p>Failed to load Google Maps</p>
          <p style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
            {loadError.message}
          </p>
        </div>
      </div>
    )
  }

  if (!isLoaded) {
    return (
      <div className="live-map">
        <div className="map-placeholder">
          <div className="loading-spinner"></div>
          <p>Loading map...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="live-map">
      <GoogleMap
        mapContainerStyle={mapContainerStyle}
        center={mapCenter}
        zoom={14}
        onLoad={onMapLoad}
        options={{
          styles: darkMapStyles,
          disableDefaultUI: false,
          zoomControl: true,
          mapTypeControl: false,
          streetViewControl: false,
          fullscreenControl: true,
        }}
      >
        {/* Ambulance Marker (Blue) */}
        {activeAmbulance?.latitude && activeAmbulance?.status === 'ACTIVE' && (
          <Marker
            position={{
              lat: activeAmbulance.latitude,
              lng: activeAmbulance.longitude,
            }}
            icon={{
              url: 'data:image/svg+xml,' + encodeURIComponent(`
                <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 40 40">
                  <circle cx="20" cy="20" r="18" fill="#3b82f6" stroke="#ffffff" stroke-width="3"/>
                  <text x="20" y="26" text-anchor="middle" font-size="18">🚑</text>
                </svg>
              `),
              scaledSize: { width: 40, height: 40 },
            }}
            title="Ambulance (Active)"
          />
        )}

        {/* Hospital Markers (Green/Red) */}
        {hospitals.map((hospital) => {
          if (!hospital.location?.lat || !hospital.location?.lon) return null
          const isReady = hospital.status === 'READY'
          return (
            <Marker
              key={hospital.id}
              position={{
                lat: hospital.location.lat,
                lng: hospital.location.lon,
              }}
              icon={{
                url: 'data:image/svg+xml,' + encodeURIComponent(`
                  <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32">
                    <circle cx="16" cy="16" r="14" fill="${isReady ? '#22c55e' : '#ef4444'}" stroke="#ffffff" stroke-width="2"/>
                    <text x="16" y="21" text-anchor="middle" font-size="14">🏥</text>
                  </svg>
                `),
                scaledSize: { width: 32, height: 32 },
              }}
              title={`${hospital.name} (${hospital.status})`}
            />
          )
        })}

        {/* Path from ambulance to destination */}
        {pathCoords.length === 2 && (
          <Polyline
            path={pathCoords}
            options={{
              strokeColor: '#3b82f6',
              strokeOpacity: 0.8,
              strokeWeight: 4,
              geodesic: true,
            }}
          />
        )}
      </GoogleMap>

      {/* Coordinate overlay */}
      {activeAmbulance?.status === 'ACTIVE' && activeAmbulance?.latitude && (
        <div className="map-overlay-info">
          <span style={{ fontSize: '16px' }}>📡</span>
          <div className="coord">
            {activeAmbulance.latitude.toFixed(6)}, {activeAmbulance.longitude.toFixed(6)}
          </div>
        </div>
      )}
    </div>
  )
}

export default LiveMap
