<template>
  <img alt="Vue logo" src="./assets/logo.png">
  <button @click="handleButtonClick">点击 1 按钮{{ count }}</button>
  <HelloWorld msg="Welcome to Your Vue.js App"/>
</template>

<script>
import HelloWorld from './components/HelloWorld.vue'
import { ref } from 'vue'

export default {
  name: 'App',
  components: {
    HelloWorld
  },

  setup() {
    const count = ref(10)

    function handleButtonClick() {
      count.value++
    }

    return {
      count,
      handleButtonClick
    }
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>

