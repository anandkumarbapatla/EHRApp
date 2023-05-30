//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EHRContract {
    struct EHR {
        string patientName;
        uint256 dateOfBirth;
        string gender;
        string bloodType;
        string[] allergies;
        mapping(uint256 => Medication) medications;
        mapping(uint256 => MedicalEvent) medicalHistory;
        uint256 medicationsCount;
        uint256 medicalEventsCount;
        uint256 timestamp;
    }

    struct Medication {
        string name;
        string dosage;
        string instructions;
    }

    struct MedicalEvent {
        string eventType;
        uint256 date;
        string description;
    }

    mapping(address => mapping(uint256 => EHR)) private patientRecords;
    mapping(address => uint256) private patientRecordsCount;

    event EHRAdded(
        address indexed patient,
        string patientName,
        uint256 dateOfBirth,
        string gender,
        string bloodType,
        string[] allergies,
        uint256 indexed timestamp
    );

    function addEHR(
        string memory _patientName,
        uint256 _dateOfBirth,
        string memory _gender,
        string memory _bloodType,
        string[] memory _allergies
    ) public {
        uint256 recordCount = patientRecordsCount[msg.sender];

        EHR storage newRecord = patientRecords[msg.sender][recordCount];
        newRecord.patientName = _patientName;
        newRecord.dateOfBirth = _dateOfBirth;
        newRecord.gender = _gender;
        newRecord.bloodType = _bloodType;
        newRecord.allergies = _allergies;
        newRecord.medicationsCount = 0;
        newRecord.medicalEventsCount = 0;
        newRecord.timestamp = block.timestamp;

        patientRecordsCount[msg.sender]++;

        emit EHRAdded(
            msg.sender,
            _patientName,
            _dateOfBirth,
            _gender,
            _bloodType,
            _allergies,
            block.timestamp
        );
    }

    function addMedication(
        uint256 ehrIndex,
        string memory _name,
        string memory _dosage,
        string memory _instructions
    ) public {
        require(ehrIndex < patientRecordsCount[msg.sender], "Invalid index");

        EHR storage ehr = patientRecords[msg.sender][ehrIndex];
        uint256 medicationsCount = ehr.medicationsCount;

        Medication storage newMedication = ehr.medications[medicationsCount];
        newMedication.name = _name;
        newMedication.dosage = _dosage;
        newMedication.instructions = _instructions;

        ehr.medicationsCount++;
    }

    function addMedicalEvent(
        uint256 ehrIndex,
        string memory _eventType,
        uint256 _date,
        string memory _description
    ) public {
        require(ehrIndex < patientRecordsCount[msg.sender], "Invalid index");

        EHR storage ehr = patientRecords[msg.sender][ehrIndex];
        uint256 medicalEventsCount = ehr.medicalEventsCount;

        MedicalEvent storage newEvent = ehr.medicalHistory[medicalEventsCount];
        newEvent.eventType = _eventType;
        newEvent.date = _date;
        newEvent.description = _description;

        ehr.medicalEventsCount++;
    }

    function getEHRCount() public view returns (uint256) {
        return patientRecordsCount[msg.sender];
    }

    function getEHRByIndex(uint256 index)
        public
        view
        returns (
            string memory,
            uint256,
            string memory,
            string memory,
            string[] memory,
            uint256
        )
    {
        require(index < patientRecordsCount[msg.sender], "Invalid index");

        EHR storage ehr = patientRecords[msg.sender][index];
        return (
            ehr.patientName,
            ehr.dateOfBirth,
            ehr.gender,
            ehr.bloodType,
            ehr.allergies,
            ehr.timestamp
        );
    }

    function getMedicationCount(uint256 ehrIndex) public view returns (uint256) {
        require(ehrIndex < patientRecordsCount[msg.sender], "Invalid index");

        return patientRecords[msg.sender][ehrIndex].medicationsCount;
    }

    function getMedicationByIndex(uint256 ehrIndex, uint256 medicationIndex)
        public
        view
        returns (string memory, string memory, string memory)
    {
        require(ehrIndex < patientRecordsCount[msg.sender], "Invalid index");
        require(
            medicationIndex < patientRecords[msg.sender][ehrIndex].medicationsCount,
            "Invalid medication index"
        );

        Medication storage medication = patientRecords[msg.sender][ehrIndex].medications[medicationIndex];
        return (medication.name, medication.dosage, medication.instructions);
    }

    function getMedicalEventCount(uint256 ehrIndex) public view returns (uint256) {
        require(ehrIndex < patientRecordsCount[msg.sender], "Invalid index");

        return patientRecords[msg.sender][ehrIndex].medicalEventsCount;
    }

    function getMedicalEventByIndex(uint256 ehrIndex, uint256 eventIndex)
        public
        view
        returns (string memory, uint256, string memory)
    {
        require(ehrIndex < patientRecordsCount[msg.sender], "Invalid index");
        require(
            eventIndex < patientRecords[msg.sender][ehrIndex].medicalEventsCount,
            "Invalid event index"
        );

        MedicalEvent storage medEvent = patientRecords[msg.sender][ehrIndex].medicalHistory[eventIndex];
        return (medEvent.eventType, medEvent.date, medEvent.description);
    }
}
