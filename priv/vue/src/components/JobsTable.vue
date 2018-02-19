<template>
  <b-table small :items="jobs" :fields="fields" show-empty>
    <template slot="HEAD_actions" slot-scope="head">
      {{head.label}} &nbsp;
      <input type="checkbox" @click.stop="toggle_selected" :checked="all_selected">
    </template>
    <template slot="actions" slot-scope="item">
      <input type="checkbox" name="checked" :key="item.index" :value="item.item" @click.stop v-model="checked">
    </template>
  </b-table>
</template>

<script>
export default {
  name: 'JobsTable',
  props: ['jobs'],
  data () {
    return {
      fields: {
        id: {
          label: 'ID'
        },
        module: {
          label: 'Module'
        },
        retry_count: {
          label: 'Total retries',
          'class': 'text-right'
        },
        actions: {
          label: 'All',
          'class': 'text-right'
        }
      },
      checked: []
    }
  },

  beforeMount () {
    this.$emit('mounting-jobs-table')
  },

  computed: {
    all_selected () {
      return this.jobs.length !== 0 && this.jobs.length === this.checked.length
    }
  },

  methods: {
    toggle_selected () {
      if (this.all_selected) {
        this.checked = []
      } else {
        this.checked = this.jobs.slice()
      }
    }
  },

  watch: {
    checked (oldVal, newVal) {
      if (oldVal !== newVal) {
        this.$emit('checked-changed', {
          checked: this.checked,
          all_selected: this.all_selected,
          nothing_selected: this.checked.length === 0
        })
      }
    }
  }
}
</script>
