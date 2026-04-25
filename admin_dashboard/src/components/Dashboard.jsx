import React from 'react'
import { useAmbulance } from '../hooks/useAmbulance'
import { useHospitals } from '../hooks/useHospitals'
import Navbar from './Navbar'
import AlertBanner from './AlertBanner'
import LiveMap from './LiveMap'
import InfoPanel from './InfoPanel'
import HospitalManagement from './HospitalManagement'

function Dashboard({ user }) {
  const { ambulances, activeAmbulance, loading: ambLoading } = useAmbulance()
  const { hospitals, loading: hospLoading, updateHospital } = useHospitals()

  if (ambLoading || hospLoading) {
    return (
      <div className="loading-screen">
        <div className="loading-spinner"></div>
        <p className="loading-text">Loading dashboard data...</p>
      </div>
    )
  }

  return (
    <div className="dashboard" id="admin-dashboard">
      {/* Top Navigation */}
      <Navbar user={user} activeAmbulance={activeAmbulance} />

      {/* Emergency Alert Banner */}
      <AlertBanner activeAmbulance={activeAmbulance} hospitals={hospitals} />

      {/* Dashboard Content Grid */}
      <div className="dashboard-content">
        {/* Live Map Area */}
        <div className="map-area">
          <LiveMap
            activeAmbulance={activeAmbulance}
            hospitals={hospitals}
          />
        </div>

        {/* Side Panel — Info */}
        <div className="side-panel">
          <InfoPanel
            activeAmbulance={activeAmbulance}
            hospitals={hospitals}
          />
        </div>

        {/* Bottom Panel — Hospital Management */}
        <div className="bottom-panel">
          <HospitalManagement
            hospitals={hospitals}
            updateHospital={updateHospital}
          />
        </div>
      </div>
    </div>
  )
}

export default Dashboard
