// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract ArrayStruct {
    // 固定长度的数组
    uint[5] array1;
    // 可变长度
    uint[] array2;

    // 初始化可变长度
    // uint[] array3 = new uint[](3);

    function initArray() external pure returns (uint[] memory) {
        uint[] memory x = new uint[](3);

        for (uint i = 0; i < 3; i++) {
            x[i] = i + 1;
        }
        return x;
    }

    function arrayPush() external returns (uint[] memory) {
        uint[2] memory a = [uint(1), 2];
        array2 = a;
        array2.push(3);
        return array2;
    }

    // -------------------------------------------------结构体----------------------------------------
    struct Student {
        uint256 id;
        uint256 score;
    }
    // 初始化一个结构体
    Student student;

    // 在函数中创建一个storage的struct的引用,并修改里面的值
    function initStudent1() external {
        Student storage _student = student;
        _student.id = 1;
        _student.score = 100;
    }

    // 直接修改值
    function initStudent2() external {
        student.id = 2;
        student.score = 80;
    }

    // 构造函数
    function initStudent3() external {
        student = Student(3, 90);
    }

    function initStudent4() external {
        student = Student({id: 4, score: 60});
    }

    // -------------------------------------------------枚举----------------------------------------
    enum ActionSet {
        Buy,
        Hold,
        Sell
    }
    // 初始化一个枚举值
    ActionSet action = ActionSet.Buy;

    function enumToUint() external view returns (uint) {
        return uint(action);
    }
}
