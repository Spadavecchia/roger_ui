<template>
  <div class="container">
    <b-row class="my-1">
      <b-col cols="2">
        <b-pagination @change="change_page"
                      size="sm" :total-rows="total_queues"
                      :per-page="page_size">
        </b-pagination>
      </b-col>
      <b-col cols="8">
        <b-form-input @input="change_filter" placeholder="Type to Filter" autofocus/>
      </b-col>
      <b-col cols="2">
        <b-button-toolbar class="my-1">
          <b-button-group size="sm">
            <b-btn :disabled="nothing_selected" @click="run_action('resume')" class="mx-1 mdi mdi-play"></b-btn>
            <b-btn :disabled="nothing_selected" @click="run_action('pause')" class="mdi mdi-pause"></b-btn>
            <b-btn :disabled="nothing_selected" @click="run_action('purge')"
                   class="mx-1 mdi mdi-delete-forever"></b-btn>
          </b-button-group>
        </b-button-toolbar>
      </b-col>
    </b-row>
    <b-table small :items="queues" :fields="fields" show-empty>
      <template slot="HEAD_actions" slot-scope="head">
        {{head.label}} &nbsp;
        <input type="checkbox" @click.stop="toggle_selected" :checked="all_selected">
      </template>
      <template slot="actions" slot-scope="item">
        <input type="checkbox" name="checked" :key="item.index" :value="item.item" @click.stop v-model="checked_queues">
      </template>
      <template slot="show_jobs" slot-scope="row">
        <b-button size="sm" @click.stop="row.toggleDetails" class="mr-2">
          {{ row.detailsShowing ? 'Hide' : 'Show'}} Jobs
        </b-button>
      </template>
      <template slot="row-details" slot-scope="row">
        <b-card title="Jobs">
          <jobs-table
            @mounting-jobs-table="load_jobs(row.item.partition_name, row.item.queue_name)"
            :jobs="jobs">
          </jobs-table>
        </b-card>
      </template>
    </b-table>
  </div>
</template>

<script>
// noinspection NpmUsedModulesInstalled
import debounce from 'lodash.debounce'
// noinspection NpmUsedModulesInstalled
import JobsTable from '@/components/JobsTable'

export default {
  name: 'Queues',
  data () {
    return {
      checked_queues: [],
      fields: {
        qualified_queue_name: {
          label: 'Name'
        },
        paused: {
          label: 'Status',
          formatter: 'is_paused'
        },
        message_count: {
          label: 'Count',
          'class': 'text-right'
        },
        actions: {
          label: 'All',
          'class': 'text-right'
        },
        show_jobs: {
          label: ' ',
          'class': 'text-center'
        }
      },
      jobs: [],
      queues: [],
      total_queues: 0,
      current_page: 1,
      page_size: 10,
      filter: ''
    }
  },

  components: {
    'jobs-table': JobsTable
  },

  computed: {
    all_selected () {
      return this.queues.length === this.checked_queues.length
    },
    nothing_selected () {
      return this.checked_queues.length === 0
    }
  },

  methods: {
    is_paused (value) {
      return value ? 'paused' : 'running'
    },

    load_jobs (partitionName, queueName) {
      // noinspection UnterminatedStatementJS
      console.log(partitionName)
      // noinspection UnterminatedStatementJS
      console.log(queueName)
      this.$http
        .get(`/api/jobs/${partitionName}/${queueName}`)
        .then(response => {
          this.jobs = response.data.queued_jobs
        })
        .catch(error => {
          console.log(error)
        })
    },

    refresh_queues () {
      // noinspection UnterminatedStatementJS
      this.checked_queues = []
      this.$http
        .get(`/api/queues/${this.page_size}/${this.current_page}`, { params: { filter: this.filter } })
        .then(response => {
          // noinspection UnterminatedStatementJS
          this.queues = response.data.queues
          this.total_queues = response.data.total
        })
        .catch(error => {
          console.log(error)
        })
    },

    action_over_queues (action, params) {
      this.$http
        .put(`/api/queues/${action}`, params)
        .then(this.refresh_queues)
    },

    run_action (action) {
      if (this.nothing_selected) { // noinspection UnterminatedStatementJS
        return
      }
      // noinspection UnterminatedStatementJS
      let params = this.all_selected ? { filter: this.filter } : { queues: this.checked_queues }
      // noinspection UnterminatedStatementJS
      console.log(params)
      this.action_over_queues(action, params)
    },

    change_page (page) {
      // noinspection UnterminatedStatementJS
      this.current_page = page
      this.refresh_queues()
    },

    change_filter: debounce(function (filter) {
      // noinspection UnterminatedStatementJS
      this.current_page = 1
      // noinspection UnterminatedStatementJS
      this.filter = filter
      this.refresh_queues()
    }, 400),

    toggle_selected () {
      if (this.all_selected) {
        this.checked_queues = []
      } else {
        this.checked_queues = this.queues.slice()
      }
    }
  },

  created () {
    this.refresh_queues()
  }
}
</script>
