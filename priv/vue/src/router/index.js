import Vue from 'vue'
import Router from 'vue-router'
import Home from '@/components/Home'
import Queues from '@/components/Queues'
import Jobs from '@/components/Jobs'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'Home',
      component: Home
    },
    {
      path: '/queues',
      name: 'Queues',
      component: Queues
    },
    {
      path: '/jobs',
      name: 'Jobs',
      component: Jobs
    }
  ]
})
