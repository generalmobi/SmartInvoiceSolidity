pragma solidity ^0.4.15;

import '../Utilities/Ownable.sol';

contract SmartInvoice is Ownable {

    Invoice[] invoiceList;
    uint invoiceCount;
    address[] invoiceSuppliers;
    address[] _listOfBuyers;
    uint[] _dateOfBuyers;

    event AddedInvoice(address operator, uint invoiceId, uint issueDate, address supplier, address currentBuyer);

    function SmartInvoice() {

    }


    function getInvoiceLength() public constant returns (uint) {
        return invoiceList.length;
    }

    function getInvoice(uint invoiceId) public constant returns (address,address,uint,uint,uint,bool,uint) {
        address _supplier = invoiceList[invoiceId].supplier;
        address _currentBuyer = invoiceList[invoiceId].currentBuyer;
        uint _totalValue = invoiceList[invoiceId].totalValue;
        uint _invoiceId = invoiceId;
        uint _dueDate = invoiceList[invoiceId].dueDate;
        bool _isValid = invoiceList[invoiceId].isValid;

        uint _currentRiskRating = invoiceList[invoiceId].currentRiskRating;
	return (_supplier,_currentBuyer,_totalValue,_invoiceId,_dueDate,_isValid,_currentRiskRating);
    }

    function getInvoiceRiskRating(uint invoiceId) public constant returns(uint,uint) {
        uint _currentRiskRating = invoiceList[invoiceId].currentRiskRating;
        uint _dateRatingApplied = invoiceList[invoiceId].dateRatingApplied;
        return (_currentRiskRating,_dateRatingApplied);
    }

    function addInvoice(
        address _currentBuyer,
        uint _totalValue,
        uint _issueDate,
        uint _dueDate,
        uint _currentRiskRating,
        uint _dateRatingApplied,
        bool _isValid,
        uint _invalidDate) {
        
        Invoice memory _inn;
        _inn.supplier = msg.sender;
        _inn.currentBuyer = _currentBuyer;
        _inn.totalValue = _totalValue;
        _inn.issueDate = _issueDate;
        _inn.dueDate = _dueDate;
        _inn.currentRiskRating = _currentRiskRating;
        _inn.dateRatingApplied = now;
        _inn.isValid = _isValid;
        _inn.invalidDate = _invalidDate;
        _inn.invoiceState = State.Invoicing;

        invoiceList.push(_inn);
        invoiceCount = invoiceCount + 1;
        //invoiceSuppliers[invoiceCount - 1] = _inn.supplier;
        invoiceSuppliers.push(msg.sender);

        AddedInvoice(msg.sender, invoiceCount, now,_inn.supplier,_currentBuyer);
    }

    function applyRiskRating(uint invoiceId, uint rating) onlyOwner {
        Invoice memory _invoice = invoiceList[invoiceId];
        require (_invoice.supplier != 0x0);

        invoiceList[invoiceId].currentRiskRating = rating;
        invoiceList[invoiceId].dateRatingApplied = now;
    }

    function sellInvoice(uint invoiceId, address newBuyer) {
        require(newBuyer != 0x0);
        Invoice memory _invoice = invoiceList[invoiceId];
        require (_invoice.supplier != 0x0);
        require (_invoice.currentBuyer == msg.sender);

        //invoiceList[invoiceId].listOfBuyers.push(newBuyer);
        invoiceList[invoiceId].currentBuyer = newBuyer;
        //invoiceList[invoiceId].dateOfBuyers.push(now);
    }

    function invalidateInvoice(uint invoiceId) {
        Invoice memory _invoice = invoiceList[invoiceId];
        require (_invoice.supplier != 0x0);
        require (_invoice.supplier == msg.sender);

        invoiceList[invoiceId].isValid = false;
        invoiceList[invoiceId].invalidDate = now;
        invoiceList[invoiceId].invoiceState = State.Invalidated;
    }

    function finishInvoice(uint invoiceId) {
        Invoice memory _invoice = invoiceList[invoiceId];
        require (_invoice.supplier != 0x0);
        require (_invoice.supplier == msg.sender);

        invoiceList[invoiceId].invoiceState = State.Finished;
    }

    function clear() {
        invoiceCount = 0;
    }

    enum State {
        Invoicing,
        Invalidated,
        Finished
    }
    
    struct Invoice {
        address supplier;
        address currentBuyer;
        uint totalValue;
        uint issueDate;
        uint dueDate;
        uint currentRiskRating;
        uint dateRatingApplied;
        bool isValid;
        uint invalidDate;
        State invoiceState;
    }
}
