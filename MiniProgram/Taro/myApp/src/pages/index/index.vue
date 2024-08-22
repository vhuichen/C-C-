<template>
  <view class="index">
    <text>{{ msg }}</text>
  </view>
  <button type="primary" @click="msg = 'Hello world'">Change Message</button>
  <button type="primary" @click="goto_path">Change Message</button>
  <button type="primary" onclick={this.goto_path.bind(this)}>Change Message</button>
  <button onClick={this.leftDrawerClick.bind(this)}>左边滑出</button>
  <View onClick={this.rightDrawerClick.bind(this)}>右边滑出</View>
</template>

<script>
import { ref } from 'vue'
import './index.scss'

export default {
  setup () {
    const msg = ref('Hello world my name is vvv')
    return {
      msg
    }
  },
  methods: {
    goto_path () {
      console.log('goto_path')
      Taro.navigateTo({
        url: '/pages/about/about'
      })
    },
    leftDrawerClick () {
      console.log('leftDrawerClick')
    },
    rightDrawerClick () {
      console.log('rightDrawerClick')

    }
  }
}

// function goto_path() {
//   console.log('goto_path')
//   Taro.navigateTo({
//     url: '/pages/about/about'
//   })
// }

// function leftDrawerClick () {
//     this.setState({
//       leftDrawerShow: !this.state.leftDrawerShow,
//     })
//   }

//   function rightDrawerClick () {
//     this.setState({
//       leftDrawerShow: !this.state.leftDrawerShow,
//     })
//   }
</script>
