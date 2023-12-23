<script>
export let additionalStyle = ""
</script>

<div class="drop-shadow-tile" style="{additionalStyle}">
  <slot></slot>
</div>

<style>
  .drop-shadow-tile{
    background: rgba(255,255,255,1);
    padding: 20px;
    border-radius: 6px;
    box-shadow: 0px 2px 4px rgba(0,0,0,0.2);
    margin: 0;
  }
</style>
