<template>
    <view class="index">
      <text>{{ msg }}</text>
    </view>
    <view class="view">
      <text class="text">{{ msg2 }}</text>
    </view>
  </template>
  
  <script>
  import { ref } from 'vue'
  import './view.scss'
  
  export default {
    setup() {
      const msg = ref('Hello world')
      const msg2 = ref('Hello world 2')
      return {
        msg,
        msg2
      }
    }
  }
  </script>
  