<template>
    <button @click="handleButtonClick">点击按钮{{ count }}</button>
    <button @click="count++">点击按钮{{ count }}</button>
    <button onClick={this.handleButtonClick}>点击按钮{{ count }}</button>
    <button onClick="console.log('tap')">点击按钮{{ count }}</button>
</template>


<script>
import { ref } from 'vue';

export default {
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