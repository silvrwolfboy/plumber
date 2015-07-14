---
layout: page
title: GitHub Webhook
comments: true
---

GitHub supports "Webhooks" to notify you of changes. In <a href="https://developer.github.com/webhooks/" target="_blank">their own words</a>:

> Webhooks allow you to build or set up integrations which subscribe to certain events on GitHub.com. When one of those events is triggered, we’ll send a HTTP POST payload to the webhook’s configured URL. Webhooks can be used to update an external issue tracker, trigger CI builds, update a backup mirror, or even deploy to your production server. You’re only limited by your imagination.

Since so many R packages are developed on GitHub, this can be a useful integration. You might want to have R respond to new issues created for a repository, evaluate changes to data or code on GitHub, or just about anything else you can imagine. 

### Setup GitHub Webhook

The best guide to setting up a GitHub Webhook is the <a href="https://developer.github.com/webhooks/" target="_blank">official documentation page</a>. In brief...

1. Navigate to the "Settings" page of your repository.
2. Click the "Webhooks & Services" tab in the sidebar.
3. Click the "Add webhook" button.
4. For the "Payload URL", use the URL at which your plumbr POST endpoint is exposed, set the "Content type" to `application/x-www-form-urlencoded`, and enter a secret key.
5. Click "Add webhook"

At this point, any commits that are pushed to that repository will trigger a POST request to the URL you specified. You can use code like the example below to respond to these triggers.

## Example

In this example, we'll demonstrate how to setup an plumbr endpoint that is capable of listening for Webhook notifications from GitHub. The example will simply subscribe to `push` notitifications on the <a href="https://github.com/trestletech/plumbr/" target="_blank">plumbr repository</a> (which are triggered any time a commit is pushed to that repo) and, in response, will install the most up-to-date version of plumbr.

We'll add one additional endpoint that enables us to see what version of plumbr is installed on the system at that moment. You should find that the `sha1` value of the response matches <a href="https://github.com/trestletech/plumbr/commits/master" target="_blank">the latest commit hash in the master branch of plumbr</a>.

  <div class="row">
    <div class="col-md-6 right-border">
      <h3 class="right-title fixed-width">GET /version</h3>
      <div class="clear"></div>
      <div class="row">
        <div class="col-md-2">
          <button id="post-btn" type="submit" class="btn btn-primary">Get</button>
        </div>
        <div class="col-md-10">
          <pre>GET {{ site.plumbr_url }}/github/version</pre>
        </div>
      </div>

      <pre id="get-result" class="empty-result">Click "Get" to see the response.</pre>


    </div>
    <div class="col-md-6">
      <h3 class="fixed-width">appender.R</h3>
      {% highlight r %}
        {% include R/github-plumbr.R %}
      {% endhighlight %}
    </div>
  </div>


<script type="text/javascript">
  $(function(){
    function updateVersion(){
      $.get('{{ site.plumbr_url }}/github/version')
      .done(function(res){
        $('#get-result').text(JSON.stringify(res, null, 2)).removeClass('empty-result').fadeOut(100).fadeIn(100);
      })
      .fail(function(err){
        console.log(err);
      });
    }


    $('#post-btn').click(function(){
      updateVersion();
    });
    updateVersion();

  });
</script>