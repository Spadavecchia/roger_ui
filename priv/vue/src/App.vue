<template>
  <div class="container-fluid" id="app">
    <b-navbar toggleable="md" type="dark" variant="info">
      <b-navbar-toggle target="nav_collapse"></b-navbar-toggle>
      <b-navbar-brand href="#">Roger UI</b-navbar-brand>
      <b-collapse is-nav id="nav_collapse">
        <b-navbar-nav>
          <b-nav-item :to="'Home'">Dashboard</b-nav-item>
          <b-nav-item :to="'Queues'">Queues</b-nav-item>
          <b-nav-item :to="'Jobs'">Running Jobs</b-nav-item>
        </b-navbar-nav>
        <b-navbar-nav class="ml-auto">
          <!-- <b-button size="sm" class="my-2 my-sm-0" variant="primary" -->
          <!--   @click="toggle_autorefresh()"> -->
          <!--   <span v-if="autorefresh">Stop Autorefresh</span> -->
          <!--   <span v-else="autorefresh">Start Autorefresh</span> -->
          <!-- </b-button> -->
        </b-navbar-nav>
      </b-collapse>
    </b-navbar>
    <router-view/>
  </div>
</template>

<script>
export default {
  name: 'App'
}
</script>
