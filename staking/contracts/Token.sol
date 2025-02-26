// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Interface do ERC-20
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Contrato ERC-20
contract Token is IERC20 {
    string public name = "Token";
    string public symbol = "T";
    uint8 public decimals = 18;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Construtor: inicializa o supply total e atribui todos os tokens ao criador do contrato
    constructor(uint256 initialSupply) {
        _totalSupply = initialSupply * 10 ** uint256(decimals);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    // Retorna o total de tokens em circulação
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    // Retorna o saldo de tokens de um endereço
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    // Transfere tokens para um endereço
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(_balances[msg.sender] >= amount, "Saldo insuficiente");
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // Retorna a quantidade de tokens que um endereço pode gastar em nome de outro
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // Aprova um endereço para gastar uma quantidade de tokens em nome do remetente
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Transfere tokens de um endereço para outro, usando a permissão de gasto
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(_balances[sender] >= amount, "Saldo insuficiente");
        require(_allowances[sender][msg.sender] >= amount, "Permissao insuficiente");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Função para criar novos tokens (apenas o dono do contrato deve poder chamar)
    function mint(address account, uint256 amount) public {
        require(account != address(0), "Endereco invalido");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    // Função para queimar (destruir) tokens
    function burn(uint256 amount) public {
        require(_balances[msg.sender] >= amount, "Saldo insuficiente");
        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}
