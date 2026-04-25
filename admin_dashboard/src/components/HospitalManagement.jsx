import React, { useState, useEffect } from 'react'

function HospitalManagement({ hospitals, updateHospital }) {
  return (
    <div className="hospital-management">
      <h3 className="hospital-management-title">Hospital Management</h3>

      {hospitals.length === 0 ? (
        <div
          style={{
            textAlign: 'center',
            padding: '24px',
            color: 'var(--text-muted)',
            fontSize: '14px',
          }}
        >
          No hospitals found in database.
          <br />
          <span style={{ fontSize: '12px' }}>
            Add hospitals to the Firestore 'hospital' collection.
          </span>
        </div>
      ) : (
        hospitals.map((hospital) => (
          <HospitalCard
            key={hospital.id}
            hospital={hospital}
            updateHospital={updateHospital}
          />
        ))
      )}
    </div>
  )
}

function HospitalCard({ hospital, updateHospital }) {
  const [beds, setBeds] = useState(hospital.availableBeds || 0)
  const [icu, setIcu] = useState(hospital.ICUAvailable || false)
  const [status, setStatus] = useState(hospital.status || 'BUSY')
  const [saving, setSaving] = useState(false)
  const [saved, setSaved] = useState(false)

  // Sync local state when Firestore data updates
  useEffect(() => {
    setBeds(hospital.availableBeds || 0)
    setIcu(hospital.ICUAvailable || false)
    setStatus(hospital.status || 'BUSY')
  }, [hospital.availableBeds, hospital.ICUAvailable, hospital.status])

  const handleSave = async () => {
    setSaving(true)
    setSaved(false)

    const success = await updateHospital(hospital.id, {
      availableBeds: parseInt(beds, 10),
      ICUAvailable: icu,
      status: status,
    })

    setSaving(false)
    if (success) {
      setSaved(true)
      setTimeout(() => setSaved(false), 2000)
    }
  }

  const isReady = status === 'READY'

  return (
    <div className="hospital-card">
      <div className="hospital-card-header">
        <span className="hospital-name">{hospital.name || 'Unnamed Hospital'}</span>
        <span className={`hospital-status ${isReady ? 'ready' : 'busy'}`}>
          {status}
        </span>
      </div>

      <div className="hospital-fields">
        <div className="hospital-field">
          <label htmlFor={`beds-${hospital.id}`}>Available Beds</label>
          <input
            id={`beds-${hospital.id}`}
            type="number"
            min="0"
            value={beds}
            onChange={(e) => setBeds(e.target.value)}
          />
        </div>

        <div className="hospital-field">
          <label htmlFor={`status-${hospital.id}`}>Status</label>
          <select
            id={`status-${hospital.id}`}
            value={status}
            onChange={(e) => setStatus(e.target.value)}
          >
            <option value="READY">READY</option>
            <option value="BUSY">BUSY</option>
          </select>
        </div>

        <div className="hospital-field">
          <label htmlFor={`icu-${hospital.id}`}>ICU Available</label>
          <select
            id={`icu-${hospital.id}`}
            value={icu ? 'true' : 'false'}
            onChange={(e) => setIcu(e.target.value === 'true')}
          >
            <option value="true">Yes</option>
            <option value="false">No</option>
          </select>
        </div>
      </div>

      <div className="hospital-actions">
        <button
          className={`btn-save ${saved ? 'saved' : ''}`}
          onClick={handleSave}
          disabled={saving}
        >
          {saving ? 'Saving...' : saved ? '✓ Saved' : 'Save Changes'}
        </button>
      </div>
    </div>
  )
}

export default HospitalManagement
