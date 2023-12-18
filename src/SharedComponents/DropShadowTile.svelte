<script>
export let additionalStyle = ""
</script>

<div class="card" style="{additionalStyle}">
  <slot></slot>
</div>

<style>
  .card{
    background: #fff;
    padding: 20px;
    border-radius: 6px;
    box-shadow: 0px 2px 4px rgba(0,0,0,0.2);
  }
</style>
