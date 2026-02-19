// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SchoolManagement {

   

    struct Student {
        string name;
        uint256 level; // 100 - 400
        uint256 schoolFee;
        bool hasPaid;
        uint256 paymentTimestamp;
        address studentAddress;
    }

    struct Staff {
        string name;
        uint256 salary;
        uint256 lastPaymentTimestamp;
        address staffAddress;
    }

   
    // STORAGE

    mapping(address => Student) private students;
    mapping(address => Staff) private staffs;

    address[] private studentList;
    address[] private staffList;

    address public owner;

   

    event StudentRegistered(address student, string name, uint256 level);
    event SchoolFeePaid(address student, uint256 amount, uint256 timestamp);

    event StaffRegistered(address staff, string name, uint256 salary);
    event StaffPaid(address staff, uint256 amount, uint256 timestamp);

    

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // INTERNAL FEE LOGIC

    function getFeeByLevel(uint256 level) public pure returns (uint256) {
        if (level == 100) return 1 ether;
        if (level == 200) return 2 ether;
        if (level == 300) return 3 ether;
        if (level == 400) return 4 ether;

        revert("Invalid level");
    }

    // STUDENT FUNCTIONS
 
    function registerStudent(string memory _name, uint256 _level) external {
        require(_level >= 100 && _level <= 400, "Invalid level");
        require(students[msg.sender].studentAddress == address(0), "Already registered");

        uint256 fee = getFeeByLevel(_level);

        students[msg.sender] = Student({
            name: _name,
            level: _level,
            schoolFee: fee,
            hasPaid: false,
            paymentTimestamp: 0,
            studentAddress: msg.sender
        });

        studentList.push(msg.sender);

        emit StudentRegistered(msg.sender, _name, _level);
    }

    function paySchoolFee() external payable {
        Student storage student = students[msg.sender];

        require(student.studentAddress != address(0), "Not registered");
        require(!student.hasPaid, "Already paid");
        require(msg.value == student.schoolFee, "Incorrect fee amount");

        student.hasPaid = true;
        student.paymentTimestamp = block.timestamp;

        emit SchoolFeePaid(msg.sender, msg.value, block.timestamp);
    }

    function getStudent(address _student) external view returns (Student memory) {
        return students[_student];
    }

    function getAllStudents() external view returns (address[] memory) {
        return studentList;
    }

    // STAFF FUNCTIONS

    function registerStaff(string memory _name, uint256 _salary) external onlyOwner {
        require(staffs[msg.sender].staffAddress == address(0), "Already registered");

        staffs[msg.sender] = Staff({
            name: _name,
            salary: _salary,
            lastPaymentTimestamp: 0,
            staffAddress: msg.sender
        });

        staffList.push(msg.sender);

        emit StaffRegistered(msg.sender, _name, _salary);
    }

    function payStaff(address _staff) external payable onlyOwner {
        Staff storage staff = staffs[_staff];

        require(staff.staffAddress != address(0), "Staff not found");
        require(msg.value == staff.salary, "Incorrect salary amount");

        staff.lastPaymentTimestamp = block.timestamp;

        (bool success, ) = payable(_staff).call{value: msg.value}("");
        require(success, "Payment failed");

        emit StaffPaid(_staff, msg.value, block.timestamp);
    }

    function getStaff(address _staff) external view returns (Staff memory) {
        return staffs[_staff];
    }

    function getAllStaff() external view returns (address[] memory) {
        return staffList;
    }
}
