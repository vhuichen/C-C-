<template>
    <view>
        <button @click="gotoIndexPage">{{ msg }}</button>
        <button @click="goToAnotherPage">{{ msg2 }}</button>
    </view>
    <view class="my-button" @click="handleClick">
        <text>点击我</text>
    </view>
    <button @click="gotoPage">点我跳转</button>

    <button @click="handleButtonClick1">Say hello</button>

    <button @click="handleClickBtn1">按钮1</button>
    <button type="warn" @click="handleClickBtn2">按钮2</button>

    <Button @click="handleClickBtn3">按钮3</Button>

</template>

<script>
import { ref } from 'vue'
import './button.scss'
import { navigateTo } from '@tarojs/taro'
import { Button } from '@tarojs/components'

export default {
    setup() {
        const msg = ref('跳转到另一个页面')
        const msg2 = ref('跳转到另一个页面')
        
        function handleButtonClick1() {
            console.log('handleButtonClick1');
        }

        return {
            msg,
            msg2
        }
    },
    methods: {
        handleButtonClick(param1, param2) {
            console.log('按钮被点击了', param1, param2);
        },
        handleButtonClick1() {
            console.log('按钮被点击了');
        },
        handleClickBtn1() {
            console.log('按钮1被点击');
        },
        handleClickBtn2() {
            console.log('按钮2被点击');
        },
        handleClickBtn3() {
            console.log('按钮3被点击');
        }
    }
}

const goToAnotherPage = () => {
    console.log('尝试跳转')
    navigateTo({
        url: '/pages/index/index'
    })
}

const handleClick = () => {
    Taro.showToast({
        title: '按钮被点击了',
        icon: 'none'
    });
};

const name = ref('Vue.js')
function gotoPage() {
    console.log('尝试跳转 gotoPage')
    alert(`Hello ${name.value}!`)
}

function say(message) {
    alert(message)
}

function handleClickBtn3() {
    console.log('尝试跳转 gotoPage')
}

</script>
