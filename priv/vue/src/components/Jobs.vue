<template>
  <div class="container">
    <b-row class="my-1">
      <b-col cols="2">
        <b-pagination @change="change_page"
                      size="sm" :total-rows="total_jobs"
                      :per-page="page_size">
        </b-pagination>
      </b-col>
      <b-col cols="9">
        <b-form-input @input="change_filter" placeholder="Type to Filter" autofocus/>
      </b-col>
      <b-col cols="1">
        <b-button-toolbar class="my-1">
          <b-button-group size="sm">
            <b-btn :disabled="nothing_selected" @click="cancel" class="mx-1 mdi mdi-delete-forever"></b-btn>
          </b-button-group>
        </b-button-toolbar>
      </b-col>
    </b-row>
    <jobs-table @checked-changed="update_checked" :jobs="jobs"></jobs-table>
  </div>
</template>

<script>
import debounce from 'lodash.debounce'
import JobsTable from '@/components/JobsTable'

export default {
  name: 'Jobs',
  data () {
    return {
      all_selected: false,
      nothing_selected: true,
      checked: [],
      jobs: [],
      total_jobs: 0,
      current_page: 1,
      page_size: 10,
      filter: ''
    }
  },

  components: {
    'jobs-table': JobsTable
  },

  methods: {
    refresh () {
      this.checked = []
      this.$http
        .get(`/api/jobs/all/${this.page_size}/${this.current_page}`, { params: { filter: this.filter } })
        .then(response => {
          this.jobs = response.data.jobs
          this.total_jobs = response.data.total
        })
        .catch(error => {
          console.log(error)
        })
    },

    update_checked (checkedStatus) {
      this.checked = checkedStatus.checked
      this.nothing_selected = checkedStatus.nothing_selected
      this.all_selected = checkedStatus.all_selected
    },

    cancel () {
      if (this.nothing_selected) return
      let params = this.all_selected ? { filter: this.filter } : { jobs: this.checked }
      this.$http
        .delete(`/api/jobs/`, params)
        .then(this.refresh)
    },

    change_page (page) {
      this.current_page = page
      this.refresh()
    },

    change_filter: debounce(function (filter) {
      this.current_page = 1
      this.filter = filter
      this.refresh()
    }, 400)
  },

  created () {
    this.refresh()
  }
}
</script>
