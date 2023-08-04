# Getting Started

## Introduction

Let's start with an example. Suppose you are building a Disaster Alert System. When there's a flood in particular area and you want to call out to those who are affected and warn them of the impending danger.

Somleng Simple Call Flow Manager (Somleng SCFM) provides a fully featured [REST API](https://github.com/somleng/somleng-scfm/blob/master/docs/REST_API_REFERENCE.md) to manage both your inbound and outbound call flows. In this guide we'll go through how we can use the REST API to build a powerful Disaster Alert System.

Before we get started, follow the [Installation Guide](https://github.com/somleng/somleng-scfm/blob/master/docs/INSTALLATION.md) to install Somleng SCFM on your local machine.

## Managing Contacts

Now that we're all set up, let's create some contacts in our database using the REST API. This will give us some people to call and also introduce the contacts API.

### Creating

The following command creates a new contact with the phone number (msisdn) `+252662345678`. Feel free to update the phone number to your number.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/contacts --data-urlencode "msisdn=+252662345678" -u $ACCESS_TOKEN: | jq'

You should see something like:

```json
{
  "id": 1,
  "msisdn": "+252662345678",
  "metadata": {},
  "created_at": "2018-05-19T06:49:24.294Z",
  "updated_at": "2018-05-19T06:49:24.294Z",
  "account_id": 2
}
```

Note that the only required field for a contact is a msisdn (aka phone number) which must be valid and must be unique.

### Updating

Our contact is a bit hard to identify, so let's give her a name and a gender.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -XPATCH -v http://somleng-scfm:3000/api/contacts/1 -d "[metadata][name]=Alice" -d "[metadata][gender]=f" -u $ACCESS_TOKEN:'

You should see something like:

    ...
    > PATCH /api/contacts/1 HTTP/1.1
    > Host: somleng-scfm:3000
    > User-Agent: curl/7.51.0
    > Accept: */*
    > Content-Length: 22
    > Content-Type: application/x-www-form-urlencoded
    >
    * upload completely sent off: 22 out of 22 bytes
    < HTTP/1.1 204 No Content
    < X-Frame-Options: SAMEORIGIN
    < X-XSS-Protection: 1; mode=block
    < X-Content-Type-Options: nosniff
    < Cache-Control: no-cache
    < X-Request-Id: d7a4ea73-9bc5-4b17-8d15-fefc6593f4ed
    < X-Runtime: 0.007223
    <
    ...

Notice that we ran this curl command with the `-v` flag. By default updating a resource successfully returns no content. The `-v` option on curl allows us to see the headers. In this case the response is `HTTP/1.1 204 No Content` which means that the contact was updated successfully.

### Fetching

If we want proof that our contact was really is the case we can fetch the contact:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/contacts/1 -u $ACCESS_TOKEN: | jq'

You should see something like:

```json
{
  "id": 1,
  "msisdn": "+252662345678",
  "metadata": {
    "name": "Alice",
    "gender": "f"
  },
  "created_at": "2017-11-09T04:58:03.684Z",
  "updated_at": "2017-11-09T05:13:49.414Z"
}
```

### Creating more contacts

Now that we have Alice in our contacts, let's add another one for Bob:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/contacts --data-urlencode "msisdn=+252662345679" -d "[metadata][name]=Bob" -d "[metadata][gender]=m" -u $ACCESS_TOKEN: | jq'

Now you should see Bob:

```json
{
  "id": 2,
  "msisdn": "+252662345679",
  "metadata": {
    "name": "Bob",
    "gender": "m"
  },
  "created_at": "2017-11-09T05:18:59.858Z",
  "updated_at": "2017-11-09T05:18:59.858Z"
}
```

Now just for fun, let's add a third contact for the Ghostbusters.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/contacts --data-urlencode "msisdn=+85510202103" -d "metadata[name]=Ghostbusters" -u $ACCESS_TOKEN: | jq'

Now you should see the Ghostbusters:

```json
{
  "id": 3,
  "msisdn": "+85510202103",
  "metadata": {
    "name": "Ghostbusters"
  },
  "created_at": "2017-11-09T05:24:07.618Z",
  "updated_at": "2017-11-09T05:24:07.618Z"
}
```

### Indexing

Let's see see who we have in our contacts table

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/contacts -u $ACCESS_TOKEN: | jq'

    ...
    > GET /api/contacts HTTP/1.1
    > Host: somleng-scfm:3000
    > User-Agent: curl/7.51.0
    > Accept: */*
    >
    < HTTP/1.1 200 OK
    < X-Frame-Options: SAMEORIGIN
    < X-XSS-Protection: 1; mode=block
    < X-Content-Type-Options: nosniff
    < Per-Page: 25
    < Total: 3
    < Content-Type: application/json; charset=utf-8
    < ETag: W/"f46af555c8c8195492f4e4e2b2bc8d6f"
    < Cache-Control: max-age=0, private, must-revalidate
    < X-Request-Id: 82e09347-a79a-4e38-b1ad-ac56212a7b33
    < X-Runtime: 0.007498
    < Transfer-Encoding: chunked
    <
    ...

```json
[
  {
    "id": 1,
    "msisdn": "+252662345678",
    "metadata": {
      "name": "Alice",
      "gender": "f"
    },
    "created_at": "2017-11-09T04:58:03.684Z",
    "updated_at": "2017-11-09T05:13:49.414Z"
  },
  {
    "id": 2,
    "msisdn": "+252662345679",
    "metadata": {
      "name": "Bob",
      "gender": "m"
    },
    "created_at": "2017-11-09T05:18:59.858Z",
    "updated_at": "2017-11-09T05:27:17.381Z"
  },
  {
    "id": 3,
    "msisdn": "+85510202103",
    "metadata": {
      "name": "Ghostbusters"
    },
    "created_at": "2017-11-09T05:24:07.618Z",
    "updated_at": "2017-11-09T05:24:07.618Z"
  }
]
```

Note that again we specified the `-v` flag to curl in order to get the headers. If you take a closer look at the headers you'll see `Per-Page: 25` and `Total: 3`. All index requests to the REST API are paginated. This means that the maxiumum number of contacts displayed for a single request is 25. The actual number will appear in the `Total` header (in this case 3). If there are more than 25 contacts then you'll see a `Link` header with links to the first, last, next and previous pages.

### Filtering

What if we only wanted to only return the contacts who are female?

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s -g "http://somleng-scfm:3000/api/contacts?q[metadata][gender]=f" -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 1

```json
[
  {
    "id": 1,
    "msisdn": "+252662345678",
    "metadata": {
      "name": "Alice",
      "gender": "f"
    },
    "created_at": "2017-11-09T04:58:03.684Z",
    "updated_at": "2017-11-09T05:13:49.414Z"
  }
]
```

You can filter contacts by their metadata or by their msisdn (phone number).

### Deleting

Looking at our contact index, adding the Ghostbusters was just a joke so let's delete them.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -XDELETE -v "http://somleng-scfm:3000/api/contacts/3" -u $ACCESS_TOKEN:'

You should see something like:

    ...
    > DELETE /api/contacts/3 HTTP/1.1
    > Host: somleng-scfm:3000
    > User-Agent: curl/7.51.0
    > Accept: */*
    >
    < HTTP/1.1 204 No Content
    < X-Frame-Options: SAMEORIGIN
    < X-XSS-Protection: 1; mode=block
    < X-Content-Type-Options: nosniff
    < Cache-Control: no-cache
    < X-Request-Id: b0ebec64-5c78-4cfd-b3f7-563c8d85388c
    < X-Runtime: 0.022870
    <
    ...

Similar to when updating resources, a successful delete returns `No Content` which can be seen in the headers above.

To double check that the Ghostbusters have been deleted you can try to fetch them:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/contacts/3 -u $ACCESS_TOKEN: | jq'

    ...
    > GET /api/contacts/3 HTTP/1.1
    > Host: somleng-scfm:3000
    > User-Agent: curl/7.51.0
    > Accept: */*
    >
    < HTTP/1.1 404 Not Found
    < Content-Type: application/json; charset=UTF-8
    < X-Request-Id: 3842fd04-011d-4b5c-aed0-0d9d4df7f7c1
    < X-Runtime: 0.004426
    < Content-Length: 34
    <
    ...

```json
{
  "status": 404,
  "error": "Not Found"
}
```

Note that the response header is `404 Not Found`.

Note that after a call has been placed to a contact you won't be able to delete them any more.

## Managing Callouts

Now that we have some contacts in our database let's create a callout. A callout represents a collection of contacts to be called for a specific purpose.

### Creating

Let's go ahead and create a callout:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/callouts -u $ACCESS_TOKEN: | jq'

Sample Response:

```json
{
  "id": 1,
  "status": "initialized",
  "call_flow_logic": null,
  "metadata": {},
  "created_at": "2017-11-19T01:55:56.869Z",
  "updated_at": "2017-11-19T01:55:56.869Z"
}
```

Note that the callout's `status` is `initialized`. This is the initial state for a callout. Callouts can be either `initialized`, `running`, `paused` or `stopped`. Also notice that our callout has no `call_flow_logic`. We'll update this later.

## Populating a Callout

Right now our callout isn't very interesting. Let's change that by populating our callout with contacts.

### Create a Callout Population

In order to populate a callout we create what's called callout population. This will allow us to preview the contacts that will be called before actually queuing the population process. A callout population is a type of batch operation. A batch operation can be one of a few different types and can be previewed and queued for processing (more on this later).

Let's go ahead and create a batch operation for populating the callout. Take notice of the url in the command below `/api/callouts/1/batch_operations`. Here `1` is the id of the callout created in the previous step. We are creating a batch operation of type `BatchOperation::CalloutPopulation` on the the callout with the id `1`.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/callouts/1/batch_operations -d type=BatchOperation::CalloutPopulation -u $ACCESS_TOKEN: | jq'

You should see something like:

```json
{
  "id": 1,
  "callout_id": 1,
  "parameters": {},
  "metadata": {},
  "status": "preview",
  "created_at": "2017-11-17T10:24:20.458Z",
  "updated_at": "2017-11-17T10:24:20.458Z"
}
```

Now that we have our callout population we can preview which contacts will participate in our callout.

Again, take notice of the url in the command below `/api/batch_operations/1/preview/contacts`. Here `1` is the id of the callout population created in the previous step. We are previewing the contacts in the callout population.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -v http://somleng-scfm:3000/api/batch_operations/1/preview/contacts -u $ACCESS_TOKEN: | jq'

You should see something like:

    ...
    < Per-Page: 25
    < Total: 2
    ...

```json
[
  {
    "id": 1,
    "msisdn": "+252662345678",
    "metadata": {
      "name": "Alice",
      "gender": "f"
    },
    "created_at": "2017-11-09T04:58:03.684Z",
    "updated_at": "2017-11-09T05:13:49.414Z"
  },
  {
    "id": 2,
    "msisdn": "+252662345679",
    "metadata": {
      "name": "Bob",
      "gender": "m"
    },
    "created_at": "2017-11-09T05:18:59.858Z",
    "updated_at": "2017-11-09T05:27:17.381Z"
  }
]
```

We can see from the response that there's `Total` of `2` contacts in the preview. This means that if we were to populate this callout now, these two contacts would be participants in the callout. Incidentally these two contacts are all of our contacts in our contacts table. This is because by default, populating a callout without a contact filter will add all contacts to the callout.

### Limiting the contacts who will participate in the callout

Typically you don't want to call everyone in your contacts table. Let's say for this example that we only want to call females.

To do this let's update the callout population specifying the `contact_filter_params` which will limit our population of the callout. Note that the `contacts_filter_params` are nested under `parameters` attribute. A batch operation will have different configurable parameters depending on the type.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -XPATCH http://somleng-scfm:3000/api/batch_operations/1 -d parameters[contact_filter_params][metadata][gender]=f -u $ACCESS_TOKEN:'

Again since we're updating a record, a successful response will return `No Content`.

    < HTTP/1.1 204 No Content

### Inspecting a callout population

Let's double check that our callout population was updated.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/batch_operations/1 -u $ACCESS_TOKEN: | jq'

You should see something like;

```json
{
  "id": 1,
  "callout_id": 1,
  "parameters": {
    "contact_filter_params": {
      "metadata": {
        "gender": "f"
      }
    }
  },
  "metadata": {},
  "status": "preview",
  "created_at": "2017-11-19T01:57:29.474Z",
  "updated_at": "2017-11-19T01:59:07.980Z"
}
```

We can see now that the `contact_filter_params` are populated with the parameters required to restrict the contacts to females only

Let's try the preview again.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -v http://somleng-scfm:3000/api/batch_operations/1/preview/contacts -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 1

```json
[
  {
    "id": 1,
    "msisdn": "+252662345678",
    "metadata": {
      "name": "Alice",
      "gender": "f"
    },
    "created_at": "2017-11-09T04:58:03.684Z",
    "updated_at": "2017-11-09T05:13:49.414Z"
  }
]
```

Now we can see from the response that there's `Total` of `1` contacts in the preview, and that that contact is in-fact female.

### Queuing the callout for population

Once we're happy with our batch operation for populating the callout we can queue it for processing. This will take some time depending on how many participations need to be created.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/batch_operations/1/batch_operation_events -d "event=queue" -u $ACCESS_TOKEN: | jq'

You should see something like:

```json
{
  "id": 1,
  "callout_id": 1,
  "parameters": {
    "contact_filter_params": {
      "metadata": {
        "gender": "f"
      }
    }
  },
  "metadata": {},
  "status": "queued",
  "created_at": "2017-11-19T01:57:29.474Z",
  "updated_at": "2017-11-19T01:59:49.166Z"
}
```

Notice that the status is now `queued`. In the background, Somleng SCFM is now busy populating your callout with callout participations. You can check the status of the population by fetching it again.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/batch_operations/1 -u $ACCESS_TOKEN: | jq'

You should see something like this:

```json
{
  "id": 1,
  "callout_id": 1,
  "parameters": {
    "contact_filter_params": {
      "metadata": {
        "gender": "f"
      }
    }
  },
  "metadata": {},
  "status": "finished",
  "created_at": "2017-11-19T01:57:29.474Z",
  "updated_at": "2017-11-19T01:59:49.237Z"
}
```

Notice that the status is now `finished`. This means that the batch operation has finished and you should now have participations in your callout.

Let's check the contacts that the batch operation added to our callout.

    < Per-Page: 25
    < Total: 1

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/batch_operations/1/contacts -u $ACCESS_TOKEN: | jq'

```json
[
  {
    "id": 1,
    "msisdn": "+252662345678",
    "metadata": {
      "name": "Alice",
      "gender": "f"
    },
    "created_at": "2017-11-10T09:50:15.301Z",
    "updated_at": "2017-11-10T09:50:27.928Z"
  }
]
```

## Managing Callout Participations

Now that we have populated our callout we should have a bunch of callout participations. A callout participation represents one contact that will participate in the callout.

Let's see what callout participations we have in our callout.

Take notice of the url in the command below `/api/callouts/1/callout_participations`. Here `1` is the id of the callout, _not_ the batch operation (although in this case the batch operation id may also have an id of `1`). Here we are fetching the participations in the callout.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/callouts/1/callout_participations -u $ACCESS_TOKEN: | jq'

You should see something like:

    < Per-Page: 25
    < Total: 1

```json
[
  {
    "id": 1,
    "callout_id": 1,
    "contact_id": 1,
    "callout_population_id": 1,
    "msisdn": "+252662345678",
    "call_flow_logic": null,
    "metadata": {},
    "created_at": "2017-11-19T01:59:49.227Z",
    "updated_at": "2017-11-19T01:59:49.227Z"
  }
]
```

As you can see we have just the one participation in the callout, which has the `contact_id: 1` (Alice).

### Listing Contacts

If we want to see exactly who will be participating in our callout we can check that too:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/callouts/1/contacts -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 1

```json
[
  {
    "id": 1,
    "msisdn": "+252662345678",
    "metadata": {
      "name": "Alice",
      "gender": "f"
    },
    "created_at": "2017-11-09T04:58:03.684Z",
    "updated_at": "2017-11-09T05:13:49.414Z"
  }
]
```

### Creating

Let's say that we changed our mind from before and we now want to include Bob into our callout. We can add Bob, by creating a callout participation directly.

In the command below we specify `contact_id=2` which is Bob's contact_id

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -XPOST -s http://somleng-scfm:3000/api/callouts/1/callout_participations -d contact_id=2 -u $ACCESS_TOKEN: | jq'

You should see something like:

```json
{
  "id": 2,
  "callout_id": 1,
  "contact_id": 2,
  "callout_population_id": null,
  "msisdn": "+252662345679",
  "call_flow_logic": null,
  "metadata": {},
  "created_at": "2017-11-19T02:01:14.643Z",
  "updated_at": "2017-11-19T02:01:14.643Z"
}
```

Bob is now the second participant in the callout. Once again we can check all the participants with:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/callouts/1/contacts -u $ACCESS_TOKEN: | jq'

```json
< Per-Page: 25
< Total: 2
```

```json
[
  {
    "id": 1,
    "msisdn": "+252662345678",
    "metadata": {
      "name": "Alice",
      "gender": "f"
    },
    "created_at": "2017-11-19T01:54:53.989Z",
    "updated_at": "2017-11-19T01:55:04.728Z"
  },
  {
    "id": 2,
    "msisdn": "+252662345679",
    "metadata": {
      "name": "Bob",
      "gender": "m"
    },
    "created_at": "2017-11-19T01:55:34.927Z",
    "updated_at": "2017-11-19T01:55:34.927Z"
  }
]
```

### Filtering

Let's say we no longer want to call Alice. We can remove Alice by deleting her participation from the callout. In order to do this we need Alice's callout participation id. We can filter the callout participations by her contact id to find her.

Notice in the command below we specify Alice's `contact_id` as a query parameter.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s -g "http://somleng-scfm:3000/api/callouts/1/callout_participations?q[contact_id]=1" -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 1

```json
[
  {
    "id": 1,
    "callout_id": 1,
    "contact_id": 1,
    "callout_population_id": 1,
    "msisdn": "+252662345678",
    "call_flow_logic": null,
    "metadata": {},
    "created_at": "2017-11-19T01:59:49.227Z",
    "updated_at": "2017-11-19T01:59:49.227Z"
  }
]
```

The `id` field in the response above is Alice's callout participation id

### Deleting

Once we have Alice's callout participation id we can delete her from the callout. Note that this doesn't delete her from the contacts table. It simply removes her from the callout.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -XDELETE http://somleng-scfm:3000/api/callout_participations/1 -u $ACCESS_TOKEN:'

As before, when deleting a resource successfully we should get a `No Content` reponse.

    < HTTP/1.1 204 No Content

For our own piece of mind let's make sure she's actually been removed from the callout.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/callouts/1/contacts -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 1

```json
[
  {
    "id": 2,
    "msisdn": "+252662345679",
    "metadata": {
      "name": "Bob",
      "gender": "m"
    },
    "created_at": "2017-11-19T01:55:34.927Z",
    "updated_at": "2017-11-19T01:55:34.927Z"
  }
]
```

### Repopulating

Let's say that we really do want Alice in the callout after all. We could just re-add her to the callout as we did for Bob, but let's add her back by requeuing or batch operation for populating the callout.

First let's check our batch operation again:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/batch_operations/1 -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 1,
  "callout_id": 1,
  "parameters": {
    "contact_filter_params": {
      "metadata": {
        "gender": "f"
      }
    }
  },
  "metadata": {},
  "status": "finished",
  "created_at": "2017-11-19T01:57:29.474Z",
  "updated_at": "2017-11-19T01:59:49.237Z"
}
```

As you can see from the response above the status of the batch operation is already `finished`. But we can requeue it again.

First let's make sure that Alice will be added again if we repopulate by previewing the contacts.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -v http://somleng-scfm:3000/api/batch_operations/1/preview/contacts -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 1

```json
[
  {
    "id": 1,
    "msisdn": "+252662345678",
    "metadata": {
      "name": "Alice",
      "gender": "f"
    },
    "created_at": "2017-11-19T01:54:53.989Z",
    "updated_at": "2017-11-19T01:55:04.728Z"
  }
]
```

Ok so we can see from the preview that Alice will added as a participant to the callout.

Finally let's go ahead and queue the batch operation. Notice that the `event` in the command below is `requeue`. We're requeuing the batch operation to populate the callout.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/batch_operations/1/batch_operation_events -d "event=requeue" -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 1,
  "callout_id": 1,
  "parameters": {
    "contact_filter_params": {
      "metadata": {
        "gender": "f"
      }
    }
  },
  "metadata": {},
  "status": "queued",
  "created_at": "2017-11-19T01:57:29.474Z",
  "updated_at": "2017-11-19T02:03:12.032Z"
}
```

Now we see that the callout population has been queued again.

Let's check again to see if it's done.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/batch_operations/1 -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 1,
  "callout_id": 1,
  "parameters": {
    "contact_filter_params": {
      "metadata": {
        "gender": "f"
      }
    }
  },
  "metadata": {},
  "status": "finished",
  "created_at": "2017-11-19T01:57:29.474Z",
  "updated_at": "2017-11-19T02:03:12.080Z"
}
```

Looks good. Now let's check to see if Alice is was populated in our callout.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/batch_operations/1/contacts -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 1

```json
[
  {
    "id": 1,
    "msisdn": "+252662345678",
    "metadata": {
      "name": "Alice",
      "gender": "f"
    },
    "created_at": "2017-11-19T01:54:53.989Z",
    "updated_at": "2017-11-19T01:55:04.728Z"
  }
]
```

Ok, we see that Alice is has been populated but what happened to Bob? If we take a closer look at the previous command notice that the URL is `api/batch_operations/1/contacts`. This command lists all the contacts which have been populated by the batch operation.

What we really want to see is who is now in our callout.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/callouts/1/contacts -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 2

```json
[
  {
    "id": 1,
    "msisdn": "+252662345678",
    "metadata": {
      "name": "Alice",
      "gender": "f"
    },
    "created_at": "2017-11-19T01:54:53.989Z",
    "updated_at": "2017-11-19T01:55:04.728Z"
  },
  {
    "id": 2,
    "msisdn": "+252662345679",
    "metadata": {
      "name": "Bob",
      "gender": "m"
    },
    "created_at": "2017-11-19T01:55:34.927Z",
    "updated_at": "2017-11-19T01:55:34.927Z"
  }
]
```

## Managing Phone Calls

Now that we're happy with our callout it's time to actually made some calls! In this example we're going to use Twilio, but if you have access to an instance of Somleng feel free to use that instead.

### Creating

In order to make calls we can use the Phone Calls API. Let's start off by simply calling Alice. We call Alice by creating a phone call on her callout participation. Remember a callout participation is the representation of a single contact being called in a callout. You can create multiple phone calls on a callout participation.

So in order to call Alice, we need her callout participation id. As shown above we can get this by filtering the callout participations by the contact id.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s -g "http://somleng-scfm:3000/api/callouts/1/callout_participations?q[contact_id]=1" -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 1

```json
[
  {
    "id": 3,
    "callout_id": 1,
    "contact_id": 1,
    "callout_population_id": 1,
    "msisdn": "+252662345678",
    "call_flow_logic": null,
    "metadata": {},
    "created_at": "2017-11-19T02:03:12.071Z",
    "updated_at": "2017-11-19T02:03:12.071Z"
  }
]
```

Ok so we can see from the response above hat Alice's callout participation ID is `3`.

Let's go ahead and create a phone call for her participation.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/callout_participations/3/phone_calls -u $ACCESS_TOKEN: | jq'

```json
{
  "errors": {
    "remote_request_params": [
      "can't be blank"
    ]
  }
}
```

Oops. The API is telling us that we can't create a phone call without `remote_request_params`. Remote request params are the parameters that will be sent to Twilio or Somleng when initiating the call. You can find a complete list of the available parameters by looking at [Twilio's REST API documentation for making calls](https://www.twilio.com/docs/api/voice/making-calls#post-parameters). The same parameters are also supported if you're using Somleng.

Let's modify our request to include some remote request parameters. Note that in the request below we are specifying only 3 parameters `from` and `url` and `method`. As per the [Twilio Documentation](https://www.twilio.com/docs/api/voice/making-calls#post-parameters) we should also specify the `to` parameter, but this will be overridden by the callout participations's msisdn so it's not required. The `from` will be the number displayed on Alice's phone when she is called, in this case `1234`. If you're using Twilio you should specify this as one of your Twilio numbers. For Somleng you can set it to whatever you like. The `url` parameter returns the the instructions for executing the call and should be a URL which returns valid [TwiML](https://www.twilio.com/docs/api/twiml). For this example we'll use Twilio's [example TwiML](https://demo.twilio.com/docs/voice.xml). Since this url is reached by a GET request and not a POST request we also need to specify the `method` parameter.

Also note that we use the lowercase, underscored version of the parameters instead of the CamelCase version. Both versions are shown in the [Twilio Documentation](https://www.twilio.com/docs/api/voice/making-calls#post-parameters).

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/callout_participations/3/phone_calls --data-urlencode "remote_request_params[from]=1234" --data-urlencode "remote_request_params[url]=https://demo.twilio.com/docs/voice.xml" -d "remote_request_params[method]=GET" -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 1,
  "callout_participation_id": 3,
  "contact_id": 1,
  "create_batch_operation_id": null,
  "queue_batch_operation_id": null,
  "queue_remote_fetch_batch_operation_id": null,
  "status": "created",
  "msisdn": "+252662345678",
  "remote_call_id": null,
  "remote_status": null,
  "remote_direction": null,
  "remote_error_message": null,
  "metadata": {},
  "remote_response": {},
  "remote_request_params": {
    "from": "1234",
    "url": "https://demo.twilio.com/docs/voice.xml",
    "method": "GET"
  },
  "remote_queue_response": {},
  "call_flow_logic": null,
  "remotely_queued_at": null,
  "created_at": "2017-11-19T02:19:41.468Z",
  "updated_at": "2017-11-19T02:19:41.468Z"
}
```

Ok this time it worked. We can confirm that our `remote_requst_params` are what we specified. We can also see the `msisdn` is Alice's number, and that the `status` of the call is `created`. We can also see that there is no `call_flow_logic` attached to this call (more on this later).

### Updating

At this point in time the phone call is in `created` state. It still hasn't been queued for remotely on Twilio or Somleng, so we are still able to update the parameters for the call.

Let's suppose that we want to update the `remote_request_params` so that Alice sees the call coming from `345` instead of `1234`.

Note that we still need to specify the `url` parameter in the update request.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -XPATCH http://somleng-scfm:3000/api/phone_calls/1 --data-urlencode "remote_request_params[from]=345" --data-urlencode "remote_request_params[url]=https://demo.twilio.com/docs/voice.xml" -d "remote_request_params[method]=GET"'

    < HTTP/1.1 204 No Content

Again updating a resources successfully will return a `204`.

### Fetching

Let's check that our call was updated successfully.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/phone_calls/1 -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 1,
  "callout_participation_id": 3,
  "contact_id": 1,
  "create_batch_operation_id": null,
  "queue_batch_operation_id": null,
  "queue_remote_fetch_batch_operation_id": null,
  "status": "created",
  "msisdn": "+252662345678",
  "remote_call_id": null,
  "remote_status": null,
  "remote_direction": null,
  "remote_error_message": null,
  "metadata": {},
  "remote_response": {},
  "remote_request_params": {
    "from": "345",
    "url": "https://demo.twilio.com/docs/voice.xml",
    "method": "GET"
  },
  "remote_queue_response": {},
  "call_flow_logic": null,
  "remotely_queued_at": null,
  "created_at": "2017-11-19T02:19:41.468Z",
  "updated_at": "2017-11-19T02:36:22.692Z"
}
```

Now we can see that our `remote_request_params` have been updated.

As mentioned before, it's possible to create multiple calls for a single callout participation. Let's say we want call Alice multiple times. To do this, let's create another call for Alice's callout participation.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/callout_participations/3/phone_calls --data-urlencode "remote_request_params[from]=1234" --data-urlencode "remote_request_params[url]=https://demo.twilio.com/docs/voice.xml" -d "remote_request_params[method]=GET" -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 2,
  "callout_participation_id": 3,
  "contact_id": 1,
  "create_batch_operation_id": null,
  "queue_batch_operation_id": null,
  "queue_remote_fetch_batch_operation_id": null,
  "status": "created",
  "msisdn": "+252662345678",
  "remote_call_id": null,
  "remote_status": null,
  "remote_direction": null,
  "remote_error_message": null,
  "metadata": {},
  "remote_response": {},
  "remote_request_params": {
    "from": "1234",
    "url": "https://demo.twilio.com/docs/voice.xml",
    "method": "GET"
  },
  "remote_queue_response": {},
  "call_flow_logic": null,
  "remotely_queued_at": null,
  "created_at": "2017-11-19T02:39:37.719Z",
  "updated_at": "2017-11-19T02:39:37.719Z"
}
```

### Indexing

Now that we have created a second phone call for Alice's callout participation, we can view all her phone calls by indexing under the callout participation.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/callout_participations/3/phone_calls -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 2

```json
[
  {
    "id": 1,
    "callout_participation_id": 3,
    "contact_id": 1,
    "create_batch_operation_id": null,
    "queue_batch_operation_id": null,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "created",
    "msisdn": "+252662345678",
    "remote_call_id": null,
    "remote_status": null,
    "remote_direction": null,
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "345",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {},
    "call_flow_logic": null,
    "remotely_queued_at": null,
    "created_at": "2017-11-19T02:19:41.468Z",
    "updated_at": "2017-11-19T02:36:22.692Z"
  },
  {
    "id": 2,
    "callout_participation_id": 3,
    "contact_id": 1,
    "create_batch_operation_id": null,
    "queue_batch_operation_id": null,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "created",
    "msisdn": "+252662345678",
    "remote_call_id": null,
    "remote_status": null,
    "remote_direction": null,
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {},
    "call_flow_logic": null,
    "remotely_queued_at": null,
    "created_at": "2017-11-19T02:39:37.719Z",
    "updated_at": "2017-11-19T02:39:37.719Z"
  }
]
```

### Deleting

Phone calls which have a `status` of `created` can also be deleted, since they have not yet been enqueued.

Let's go ahead and delete the most recent call that we just created for Alice's callout participation.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -XDELETE http://somleng-scfm:3000/api/phone_calls/2 -u $ACCESS_TOKEN:'

    < HTTP/1.1 204 No Content

Again for a successful `DELETE` request we should get a `204` response.

Let's go and list the phone calls again to see if it has in fact been deleted. Note that in the request below we don't specify the callout participation ID. This request will list _all_ of the phone calls in the database so it's normally not what you want. But for this example, after deleting Alice's most recent phone call we should only have one remaining.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/phone_calls -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 1

```json
[
  {
    "id": 1,
    "callout_participation_id": 3,
    "contact_id": 1,
    "create_batch_operation_id": null,
    "queue_batch_operation_id": null,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "created",
    "msisdn": "+252662345678",
    "remote_call_id": null,
    "remote_status": null,
    "remote_direction": null,
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {},
    "call_flow_logic": null,
    "remotely_queued_at": null,
    "created_at": "2017-11-19T02:19:41.468Z",
    "updated_at": "2017-11-19T02:36:22.692Z"
  }
]
```

### Queueing Remote Calls

Ok finally we're ready to go ahead and call Alice. In order to do this we create a phone call event for the phone call and set the event to `queue`.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/phone_calls/1/phone_call_events -d event=queue -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 1,
  "callout_participation_id": 3,
  "contact_id": 1,
  "create_batch_operation_id": null,
  "queue_batch_operation_id": null,
  "queue_remote_fetch_batch_operation_id": null,
  "status": "queued",
  "msisdn": "+252662345678",
  "remote_call_id": null,
  "remote_status": null,
  "remote_direction": null,
  "remote_error_message": null,
  "metadata": {},
  "remote_response": {},
  "remote_request_params": {
    "from": "1234",
    "url": "https://demo.twilio.com/docs/voice.xml",
    "method": "GET"
  },
  "remote_queue_response": {},
  "call_flow_logic": null,
  "remotely_queued_at": null,
  "created_at": "2017-11-19T02:19:41.468Z",
  "updated_at": "2017-11-19T02:57:00.787Z"
}
```

We can see from the `status` attribute that the call has been `queued`. In the background the call should being queued on Twilio or Somleng. We can check the status of the call by fetching it again.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/phone_calls/1 -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 1,
  "callout_participation_id": 3,
  "contact_id": 1,
  "create_batch_operation_id": null,
  "queue_batch_operation_id": null,
  "queue_remote_fetch_batch_operation_id": null,
  "status": "errored",
  "msisdn": "+252662345678",
  "remote_call_id": null,
  "remote_status": null,
  "remote_direction": null,
  "remote_error_message": "Unable to create record: The requested resource /2010-04-01/Accounts//Calls.json was not found",
  "metadata": {},
  "remote_response": {},
  "remote_request_params": {
    "from": "1234",
    "url": "https://demo.twilio.com/docs/voice.xml",
    "method": "GET"
  },
  "remote_queue_response": {},
  "call_flow_logic": null,
  "remotely_queued_at": "2017-11-19T02:57:02.319Z",
  "created_at": "2017-11-19T02:19:41.468Z",
  "updated_at": "2017-11-19T02:57:02.319Z"
}
```

We can see from the `status` in the response above that the call was `errored`. If we look at the `remote_error_message` we can see the reason from Twilio or Somleng.

> Unable to create record: The requested resource /2010-04-01/Accounts//Calls.json was not found

Oops, it looks like that we're missing our Account SID.

### Configuring Twilio or Somleng

Twilio and Somleng API keys are configured with environment variables. The following environment variables are available:

    SOMLENG_ACCOUNT_SID=somleng-account-sid
    SOMLENG_AUTH_TOKEN=somleng-auth-token
    SOMLENG_CLIENT_REST_API_HOST=somleng-rest-api-host
    SOMLENG_CLIENT_REST_API_BASE_URL=somleng-rest-api-base-url
    TWILIO_ACCOUNT_SID=twilio-account-sid
    TWILIO_AUTH_TOKEN=twilio-auth-token
    PLATFORM_PROVIDER=twilio-or-somleng

If we're using Twilio, we need to set the following environment variables:

    PLATFORM_PROVIDER=twilio
    TWILIO_ACCOUNT_SID=twilio-account-sid
    TWILIO_AUTH_TOKEN=twilio-auth-token

If we're using Somleng, we would set the following environment variables:

    PLATFORM_PROVIDER=somleng
    SOMLENG_ACCOUNT_SID=somleng-account-sid
    SOMLENG_AUTH_TOKEN=somleng-auth-token
    SOMLENG_CLIENT_REST_API_HOST=somleng-rest-api-host
    SOMLENG_CLIENT_REST_API_BASE_URL=somleng-rest-api-base-url

When we boot the API server we can specify these environment variables. Let's go ahead and restart our API server with our Twilio or Somleng environment variables set. Don't forget to shutdown the running API server first (Ctrl-C from the terminal). Here's the command if you're using Twilio. Don't forget to replace the dummy values with your actual values.

    $ docker-compose run -it --rm -e PLATFORM_PROVIDER=twilio -e TWILIO_ACCOUNT_SID=twilio-account-sid -e TWILIO_AUTH_TOKEN=twilio-auth-token somleng-scfm /bin/bash -c 'bundle exec rails s'

Below is the command to use if you're using Somleng. Again don't forget to replace the dummy values with your actual values.

    $ docker-compose run -it --rm -e PLATFORM_PROVIDER=somleng -e SOMLENG_ACCOUNT_SID=somleng-account-sid -e SOMLENG_AUTH_TOKEN=somleng-auth-token -e SOMLENG_CLIENT_REST_API_HOST=somleng-rest-api-host -e SOMLENG_CLIENT_REST_API_BASE_URL=somleng-rest-api-base-url somleng-scfm /bin/bash -c 'bundle exec rails s'

### Calling again

With the server rebooted and our environment variables set correctly let's try to call Alice again. First, it's important to note that once a phone call has been queued remotely, that particular phone call cannot be retried. Instead we just need to make another phone call for Alice and queue it again.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/callout_participations/3/phone_calls --data-urlencode "remote_request_params[from]=345" --data-urlencode "remote_request_params[url]=https://demo.twilio.com/docs/voice.xml" -d "remote_request_params[method]=GET" -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 3,
  "callout_participation_id": 3,
  "contact_id": 1,
  "create_batch_operation_id": null,
  "queue_batch_operation_id": null,
  "queue_remote_fetch_batch_operation_id": null,
  "status": "created",
  "msisdn": "+252662345678",
  "remote_call_id": null,
  "remote_status": null,
  "remote_direction": null,
  "remote_error_message": null,
  "metadata": {},
  "remote_response": {},
  "remote_request_params": {
    "from": "345",
    "url": "https://demo.twilio.com/docs/voice.xml",
    "method": "GET"
  },
  "remote_queue_response": {},
  "call_flow_logic": null,
  "remotely_queued_at": null,
  "created_at": "2017-11-24T05:41:38.394Z",
  "updated_at": "2017-11-24T05:41:38.394Z"
}
```

And go ahead and queue it again.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/phone_calls/3/phone_call_events -d event=queue -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 3,
  "callout_participation_id": 3,
  "contact_id": 1,
  "create_batch_operation_id": null,
  "queue_batch_operation_id": null,
  "queue_remote_fetch_batch_operation_id": null,
  "status": "queued",
  "msisdn": "+252662345678",
  "remote_call_id": null,
  "remote_status": null,
  "remote_direction": null,
  "remote_error_message": null,
  "metadata": {},
  "remote_response": {},
  "remote_request_params": {
    "from": "345",
    "url": "https://demo.twilio.com/docs/voice.xml",
    "method": "GET"
  },
  "remote_queue_response": {},
  "call_flow_logic": null,
  "remotely_queued_at": null,
  "created_at": "2017-11-24T05:41:38.394Z",
  "updated_at": "2017-11-24T05:43:05.515Z"
}
```

Then fetch it to check it's status

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/phone_calls/3 -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 3,
  "callout_participation_id": 3,
  "contact_id": 1,
  "create_batch_operation_id": null,
  "queue_batch_operation_id": null,
  "queue_remote_fetch_batch_operation_id": null,
  "status": "remotely_queued",
  "msisdn": "+252662345678",
  "remote_call_id": "082305b2-a0e4-4921-89bf-7bb544fd6910",
  "remote_status": "queued",
  "remote_direction": "outbound-api",
  "remote_error_message": null,
  "metadata": {},
  "remote_response": {},
  "remote_request_params": {
    "from": "345",
    "url": "https://demo.twilio.com/docs/voice.xml",
    "method": "GET"
  },
  "remote_queue_response": {
    "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
    "api_version": "2010-04-01",
    "date_created": "2017-11-24T05:43:19.000+00:00",
    "date_updated": "2017-11-24T05:43:19.000+00:00",
    "direction": "outbound-api",
    "from": "345",
    "from_formatted": "+34 5 ",
    "price": 0,
    "sid": "082305b2-a0e4-4921-89bf-7bb544fd6910",
    "status": "queued",
    "subresource_uris": {},
    "to": "+252662345678",
    "to_formatted": "+252 66 234 5678",
    "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/082305b2-a0e4-4921-89bf-7bb544fd6910"
  },
  "call_flow_logic": null,
  "remotely_queued_at": "2017-11-24T05:43:20.446Z",
  "created_at": "2017-11-24T05:41:38.394Z",
  "updated_at": "2017-11-24T05:43:20.446Z"
}
```

This looks better! We can see that the `status` is now `remotely_queued` and that we have a response in the `remote_queue_response`. We can see the `remote_call_id` is present and is set to the call SID from Twilio or Somleng. We also get a timestamp in `remotely_queued_at` as to when the call was remotely queued.

### Fetching the remote status

Now that our call was queued remotely, it would be nice to see what happened to it. Using the phone call events API we can queue a job for fetching the remote status of a call.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/phone_calls/3/phone_call_events -d event=queue_remote_fetch -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 3,
  "callout_participation_id": 3,
  "contact_id": 1,
  "create_batch_operation_id": null,
  "queue_batch_operation_id": null,
  "queue_remote_fetch_batch_operation_id": null,
  "status": "remote_fetch_queued",
  "msisdn": "+252662345678",
  "remote_call_id": "082305b2-a0e4-4921-89bf-7bb544fd6910",
  "remote_status": "queued",
  "remote_direction": "outbound-api",
  "remote_error_message": null,
  "metadata": {},
  "remote_response": {},
  "remote_request_params": {
    "from": "345",
    "url": "https://demo.twilio.com/docs/voice.xml",
    "method": "GET"
  },
  "remote_queue_response": {
    "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
    "api_version": "2010-04-01",
    "date_created": "2017-11-24T05:43:19.000+00:00",
    "date_updated": "2017-11-24T05:43:19.000+00:00",
    "direction": "outbound-api",
    "from": "345",
    "from_formatted": "+34 5 ",
    "price": 0,
    "sid": "082305b2-a0e4-4921-89bf-7bb544fd6910",
    "status": "queued",
    "subresource_uris": {},
    "to": "+252662345678",
    "to_formatted": "+252 66 234 5678",
    "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/082305b2-a0e4-4921-89bf-7bb544fd6910"
  },
  "call_flow_logic": null,
  "remotely_queued_at": "2017-11-24T05:43:20.446Z",
  "created_at": "2017-11-24T05:41:38.394Z",
  "updated_at": "2017-11-24T05:44:03.102Z"
}
```

Here we see the `status` is now `remote_fetch_queued` which means that a remote fetch of the call has been queued.

Let's fetch the call again to see if it's been updated.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/phone_calls/3 -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 3,
  "callout_participation_id": 3,
  "contact_id": 1,
  "create_batch_operation_id": null,
  "queue_batch_operation_id": null,
  "queue_remote_fetch_batch_operation_id": null,
  "status": "canceled",
  "msisdn": "+252662345678",
  "remote_call_id": "082305b2-a0e4-4921-89bf-7bb544fd6910",
  "remote_status": "canceled",
  "remote_direction": "outbound-api",
  "remote_error_message": null,
  "metadata": {},
  "remote_response": {
    "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
    "api_version": "2010-04-01",
    "date_created": "2017-11-24T05:43:19.000+00:00",
    "date_updated": "2017-11-24T05:43:19.000+00:00",
    "direction": "outbound-api",
    "from": "345",
    "from_formatted": "+34 5 ",
    "price": 0,
    "sid": "082305b2-a0e4-4921-89bf-7bb544fd6910",
    "status": "canceled",
    "subresource_uris": {},
    "to": "+252662345678",
    "to_formatted": "+252 66 234 5678",
    "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/082305b2-a0e4-4921-89bf-7bb544fd6910"
  },
  "remote_request_params": {
    "from": "345",
    "url": "https://demo.twilio.com/docs/voice.xml",
    "method": "GET"
  },
  "remote_queue_response": {
    "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
    "api_version": "2010-04-01",
    "date_created": "2017-11-24T05:43:19.000+00:00",
    "date_updated": "2017-11-24T05:43:19.000+00:00",
    "direction": "outbound-api",
    "from": "345",
    "from_formatted": "+34 5 ",
    "price": 0,
    "sid": "082305b2-a0e4-4921-89bf-7bb544fd6910",
    "status": "queued",
    "subresource_uris": {},
    "to": "+252662345678",
    "to_formatted": "+252 66 234 5678",
    "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/082305b2-a0e4-4921-89bf-7bb544fd6910"
  },
  "call_flow_logic": null,
  "remotely_queued_at": "2017-11-24T05:43:20.446Z",
  "created_at": "2017-11-24T05:41:38.394Z",
  "updated_at": "2017-11-24T05:44:06.099Z"
}
```

Now we can see that the call was updated and the `status` is `canceled`. We can also see the full response from Twilio/Somleng in the `remote_response` attribute.

### Using your own call flow logic

In the previous examples we used call flow logic from Twilio. Specifically we asked Twilio/Somleng to execute the [sample TwiML](https://demo.twilio.com/docs/voice.xml) which defined our call flow logic.

We could also use the API to specify our own custom call flow logic instead. There's a little bit more to do in order to simulate a live demo here because both Twilio and Somleng need to contact your server through the Internet in order to retrieve the TwiML. Since we're running our API locally using Docker we can use something like [ngrok](https://ngrok.com/) to setup a tunnel to our local machine. The details behind setting up a [ngrok](https://ngrok.com/) tunnel are beyond the scope of this guide, but it's quite easy to do so please feel free to go ahead and setup ngrok if you want to test this out.

In order to use our own logic let's go ahead and create yet another phone call for Alice. Notice that this time we're specifying the `remote_request_params[url]` parameter AND the `remote_request_params[status_callback]` as `http://18a2c6b3.ngrok.io/api/remote_phone_call_events`. If you're using ngrok, you'll need to update this to url provided by ngrok. The path though is important `/api/remote_phone_call_events`. This is the endpoint within the API which is designed to return TwiML for our custom call flow logic. Also notice that we left out the `remote_request_params[method]` parameter. This is because, by default, Twilio and Somleng assume that it can reach your TwiML endpoint via HTTP POST. Since the somleng-scfm API endpoint at `/api/remote_phone_call_events` supports POST (and only POST) we can leave this blank.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/callout_participations/3/phone_calls --data-urlencode "remote_request_params[from]=345" --data-urlencode "remote_request_params[url]=http://18a2c6b3.ngrok.io/api/remote_phone_call_events" --data-urlencode "remote_request_params[status_callback]=http://18a2c6b3.ngrok.io/api/remote_phone_call_events" -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 4,
  "callout_participation_id": 3,
  "contact_id": 1,
  "create_batch_operation_id": null,
  "queue_batch_operation_id": null,
  "queue_remote_fetch_batch_operation_id": null,
  "status": "created",
  "msisdn": "+252662345678",
  "remote_call_id": null,
  "remote_status": null,
  "remote_direction": null,
  "remote_error_message": null,
  "metadata": {},
  "remote_response": {},
  "remote_request_params": {
    "from": "345",
    "url": "http://18a2c6b3.ngrok.io/api/remote_phone_call_events",
    "status_callback": "http://18a2c6b3.ngrok.io/api/remote_phone_call_events",
  },
  "remote_queue_response": {},
  "call_flow_logic": null,
  "remotely_queued_at": null,
  "created_at": "2017-11-24T05:45:22.310Z",
  "updated_at": "2017-11-24T05:45:22.310Z"
}
```

We can see from the output that the phone call has been created successfully with the `remote_request_params` that we specified. Also notice that the `call_flow_logic` is `null`. The `call_flow_logic` parameter allows us to specify which call flow logic will be executed when a request is received from Twilio or Somleng to the `url` endpoint. By default the `call_flow_logic` parameter is `null` which means that it will execute the default application call flow logic, which is defined [here](https://github.com/somleng/somleng-scfm/blob/master/app/models/call_flow_logic/application.rb). If you take a look at that file you'll see it's a plain ruby class which implements the `to_xml` method. The `to_xml` method returns valid TwiML using the [twilio-ruby](https://github.com/twilio/twilio-ruby) which simply says the words "Thanks for trying our documentation. Enjoy!" then plays a song.

But what if we want to use our own call flow logic? In order to do this you can define a ruby class in your application inheriting `CallFlowLogic::Base`, then implement the `to_xml` method (for some more complex examples checkout the [call_flow_logic directory](https://github.com/somleng/somleng-scfm/tree/master/app/models/call_flow_logic)). Once you have defined your call flow logic you can set it on a callout, callout participation or phone call. For this example let's try to set the call flow logic to `CallFlowLogic::AvfCapom::CapomShort` which is already defined in the [call_flow_logic directory](https://github.com/somleng/somleng-scfm/tree/master/app/models/call_flow_logic).

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s -XPATCH http://somleng-scfm:3000/api/phone_calls/5 -d call_flow_logic=CallFlowLogic::AvfCapom::CapomShort -u $ACCESS_TOKEN: | jq'

    < HTTP/1.1 422 Unprocessable Entity

```json
{
  "errors": {
    "call_flow_logic": [
      "is not included in the list"
    ]
  }
}
```

Oops. Doesn't seem to have worked. The error message suggests that our call flow logic is not included in the list of available call flow logic for the application.

### Registering your call flow logic

In order to make our custom call flow logic available, we need to register it first. You can use the environment variable `REGISTERED_CALL_FLOW_LOGIC` to define a comma separated list of call flow logic that your application uses. For example, setting the following environment variable will register the call flow logic called `CallFlowLogic::AvfCapom::CapomShort`.

    REGISTERED_CALL_FLOW_LOGIC=CallFlowLogic::AvfCapom::CapomShort

Let's go ahead and restart our API server and specify these environment variables. Don't forget to shutdown the running API server first (Ctrl-C). Also note that for brevity we have left out the Twilio and Somleng configuration variables. Be sure to add them in as well.

    $ docker-compose run -it --rm -e REGISTERED_CALL_FLOW_LOGIC=CallFlowLogic::AvfCapom::CapomShort somleng-scfm /bin/bash -c 'bundle exec rails s'

Ok let's try to use our call flow logic again.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s -XPATCH http://somleng-scfm:3000/api/phone_calls/4 -d call_flow_logic=CallFlowLogic::AvfCapom::CapomShort -u $ACCESS_TOKEN:'

    < HTTP/1.1 204 No Content

Looks better. Let's fetch the phone call again to make sure it's been updated with our call flow logic.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/phone_calls/4 -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 4,
  "callout_participation_id": 3,
  "contact_id": 1,
  "create_batch_operation_id": null,
  "queue_batch_operation_id": null,
  "queue_remote_fetch_batch_operation_id": null,
  "status": "created",
  "msisdn": "+252662345678",
  "remote_call_id": null,
  "remote_status": null,
  "remote_direction": null,
  "remote_error_message": null,
  "metadata": {},
  "remote_response": {},
  "remote_request_params": {
    "from": "345",
    "url": "http://18a2c6b3.ngrok.io/api/remote_phone_call_events"
  },
  "remote_queue_response": {},
  "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
  "remotely_queued_at": null,
  "created_at": "2017-11-24T05:45:22.310Z",
  "updated_at": "2017-11-24T05:46:07.622Z"
}
```

Now we can see that the `call_flow_logic` has been successfully updated. Finally let's go ahead and queue the call.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/phone_calls/4/phone_call_events -d event=queue -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 4,
  "callout_participation_id": 3,
  "contact_id": 1,
  "create_batch_operation_id": null,
  "queue_batch_operation_id": null,
  "queue_remote_fetch_batch_operation_id": null,
  "status": "queued",
  "msisdn": "+252662345678",
  "remote_call_id": null,
  "remote_status": null,
  "remote_direction": null,
  "remote_error_message": null,
  "metadata": {},
  "remote_response": {},
  "remote_request_params": {
    "from": "345",
    "url": "http://18a2c6b3.ngrok.io/api/remote_phone_call_events"
  },
  "remote_queue_response": {},
  "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
  "remotely_queued_at": null,
  "created_at": "2017-11-24T05:45:22.310Z",
  "updated_at": "2017-11-24T05:46:41.262Z"
}
```

We can see that the call's `status` was `queued`. As before we can go ahead and fetch the call again to see if it's been remotely queued. We can also update it's remote status.

## Phone Call Batch Operations (Create)

So far we have gone through [managing contacts](#managing-contacts), [creating callouts](#managing-callouts), [populating callouts](#populating-a-callout), [managing callout participations](#managing-callout-participations) and [managing phone calls](#managing-phone-calls) for participants.

Recall when we went through [populating callouts](#populating-a-callout) we used a batch operation to filter contacts, preview the callout population then finally queue the batch operation for creating callout participations? It turns out we can also use a batch operation for creating, remotely queuing and updating the remote status of multiple phone calls. A single batch operation can be used to create phone calls across multiple callouts.

### Create another callout

In order to demonstrate this let's go and [create a second callout](#managing-callouts) and populate it with participations.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/callouts -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 2,
  "status": "initialized",
  "call_flow_logic": null,
  "metadata": {},
  "created_at": "2017-11-23T03:13:39.136Z",
  "updated_at": "2017-11-23T03:13:39.136Z"
}
```

Now that we have our second callout, let's go and [populate it](#populating-a-callout) with callout participations.

First create a batch operation for populating our new callout:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/callouts/2/batch_operations -d type=BatchOperation::CalloutPopulation -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 2,
  "callout_id": 2,
  "parameters": {},
  "metadata": {},
  "status": "preview",
  "created_at": "2017-11-23T03:17:42.371Z",
  "updated_at": "2017-11-23T03:17:42.371Z"
}
```

Then preview the batch operation:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -v http://somleng-scfm:3000/api/batch_operations/2/preview/contacts -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 2

```json
[
  {
    "id": 1,
    "msisdn": "+252662345678",
    "metadata": {
      "name": "Alice",
      "gender": "f"
    },
    "created_at": "2017-11-23T03:12:06.684Z",
    "updated_at": "2017-11-23T03:12:55.097Z"
  },
  {
    "id": 2,
    "msisdn": "+252662345679",
    "metadata": {
      "name": "Bob",
      "gender": "m"
    },
    "created_at": "2017-11-23T03:12:21.240Z",
    "updated_at": "2017-11-23T03:12:21.240Z"
  }
]
```

Queue it for population:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/batch_operations/2/batch_operation_events -d "event=queue" -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 2,
  "callout_id": 2,
  "parameters": {},
  "metadata": {},
  "status": "queued",
  "created_at": "2017-11-23T03:17:42.371Z",
  "updated_at": "2017-11-23T03:20:14.283Z"
}
```

And finally check the participants:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/batch_operations/2/contacts -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 2

```json
[
  {
    "id": 1,
    "msisdn": "+252662345678",
    "metadata": {
      "name": "Alice",
      "gender": "f"
    },
    "created_at": "2017-11-23T03:12:06.684Z",
    "updated_at": "2017-11-23T03:12:55.097Z"
  },
  {
    "id": 2,
    "msisdn": "+252662345679",
    "metadata": {
      "name": "Bob",
      "gender": "m"
    },
    "created_at": "2017-11-23T03:12:21.240Z",
    "updated_at": "2017-11-23T03:12:21.240Z"
  }
]
```

Alice and Bob are now both participants in the first callout and the second callout. We can double check this by looking at all callout participations across all callouts.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/callout_participations -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 4

```json
[
  {
    "id": 2,
    "callout_id": 1,
    "contact_id": 2,
    "callout_population_id": null,
    "msisdn": "+252662345679",
    "call_flow_logic": null,
    "metadata": {},
    "created_at": "2017-11-24T05:37:57.777Z",
    "updated_at": "2017-11-24T05:37:57.777Z"
  },
  {
    "id": 3,
    "callout_id": 1,
    "contact_id": 1,
    "callout_population_id": 1,
    "msisdn": "+252662345678",
    "call_flow_logic": null,
    "metadata": {},
    "created_at": "2017-11-24T05:38:41.562Z",
    "updated_at": "2017-11-24T05:38:41.562Z"
  },
  {
    "id": 4,
    "callout_id": 2,
    "contact_id": 1,
    "callout_population_id": 2,
    "msisdn": "+252662345678",
    "call_flow_logic": null,
    "metadata": {},
    "created_at": "2017-11-24T05:47:50.534Z",
    "updated_at": "2017-11-24T05:47:50.534Z"
  },
  {
    "id": 5,
    "callout_id": 2,
    "contact_id": 2,
    "callout_population_id": 2,
    "msisdn": "+252662345679",
    "call_flow_logic": null,
    "metadata": {},
    "created_at": "2017-11-24T05:47:50.545Z",
    "updated_at": "2017-11-24T05:47:50.545Z"
  }
]
```

Now let's take a closer look at our actual callouts.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/callouts -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 2

```json
[
  {
    "id": 1,
    "status": "initialized",
    "call_flow_logic": null,
    "metadata": {},
    "created_at": "2017-11-23T03:13:34.487Z",
    "updated_at": "2017-11-23T03:13:34.487Z"
  },
  {
    "id": 2,
    "status": "initialized",
    "call_flow_logic": null,
    "metadata": {},
    "created_at": "2017-11-23T03:13:39.136Z",
    "updated_at": "2017-11-23T03:13:39.136Z"
  }
]
```

We can see that both of our callouts have the `status` `initialized` and that both of them have a `call_flow_logic` of `null`

### More about Callouts

For this example, let's assume that we want to use the `CallFlowLogic::AvfCapom::CapomShort` logic for all calls in the second callout, but not the first. Also let's assume that we don't want to create any phone calls for the first callout which is using a different call flow.

#### Updating

Firstly let's go ahead and update the `call_flow_logic` for the second callout. Note that you'll have to register this callout first as explained in the previous section.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -XPATCH http://somleng-scfm:3000/api/callouts/2 -d call_flow_logic="CallFlowLogic::AvfCapom::CapomShort" -u $ACCESS_TOKEN:'

    < HTTP/1.1 204 No Content

#### Fetching

Now let's fetch the callout to make sure that it was updated successfully:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/callouts/2 -u $ACCESS_TOKEN: | jq'

    {
      "id": 2,
      "status": "initialized",
      "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
      "metadata": {},
      "created_at": "2017-11-23T03:13:39.136Z",
      "updated_at": "2017-11-23T03:35:50.274Z"
    }

#### Events

Now we can see that our `call_flow_logic` has been updated to `CallFlowLogic::AvfCapom::CapomShort`, but the `status` is still `initialized`. The status of a callout can be either `initialized`, `running`, `paused` or `stopped`. We can change the status by either, `starting`, `stopping`, `pausing` or `resuming` the callout.

Since, that for this example we only want to deal with the second callout, let's go ahead and set the status to `running` by `starting` the callout.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -XPOST -s http://somleng-scfm:3000/api/callouts/2/callout_events -d "event=start" -u $ACCESS_TOKEN: | jq'

    {
      "id": 2,
      "status": "running",
      "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
      "metadata": {},
      "created_at": "2017-11-23T03:13:39.136Z",
      "updated_at": "2017-11-23T03:52:51.145Z"
    }

#### Filtering

Now that our second callout's `status` is `running` we can filter all callouts on the status. The following command lists all callouts with the `status` equal to `running`.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s -g http://somleng-scfm:3000/api/callouts?q[status]="running" -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 1

```json
[
  {
    "id": 2,
    "status": "running",
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "metadata": {},
    "created_at": "2017-11-23T03:13:39.136Z",
    "updated_at": "2017-11-23T03:52:51.145Z"
  }
]
```

To summarize this is what we just did:

1.  Created a second callout
2.  Populated it
3.  Set the call flow logic
4.  Started it

### Create a Batch Operation for creating phone calls

Let's see how we can use a batch operation for creating phone calls across callouts. First let's go ahead and create a batch operation for creating phone calls.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s -XPOST http://somleng-scfm:3000/api/batch_operations -d type=BatchOperation::PhoneCallCreate -u $ACCESS_TOKEN: | jq'

    < HTTP/1.1 422 Unprocessable Entity

```json
{
  "errors": {
    "remote_request_params": [
      "can't be blank"
    ]
  }
}
```

Oops, that didn't seem to have worked. It's saying that we haven't specified any `remote_request_params`.

When using a batch operation for creating phone calls that batch operation must be able to create valid phone calls. Recall when [creating a phone call using the phone calls API](#managing-phone-calls) that we needed to specify the `remote_request_params` when creating the phone call? The same applies for the batch operation.

Let's try again, this time specifying the `remote_request_params`. Note that for batch operations the `remote_request_params` are nested under `parameters`.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s -XPOST http://somleng-scfm:3000/api/batch_operations -d type=BatchOperation::PhoneCallCreate --data-urlencode "parameters[remote_request_params][from]=1234" --data-urlencode "parameters[remote_request_params][url]=https://demo.twilio.com/docs/voice.xml" -d "parameters[remote_request_params][method]=GET" -u $ACCESS_TOKEN: | jq'

    < HTTP/1.1 201 Created

```json
{
  "id": 3,
  "callout_id": null,
  "parameters": {
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    }
  },
  "metadata": {},
  "status": "preview",
  "created_at": "2017-11-23T04:26:06.717Z",
  "updated_at": "2017-11-23T04:26:06.717Z"
}
```

Alright that seemed to have worked. Note from the response above that the `status` is `preview`. This is similar to when we created a [batch operation for populating a callout](#populating-a-callout).

### Previewing

Now that we have our batch operation we can go ahead and preview it to see which [callout participations](#managing-callout-participations) will have phone calls created.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/batch_operations/3/preview/callout_participations -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 4

```json
[
  {
    "id": 2,
    "callout_id": 1,
    "contact_id": 2,
    "callout_population_id": null,
    "msisdn": "+252662345679",
    "call_flow_logic": null,
    "metadata": {},
    "created_at": "2017-11-24T05:37:57.777Z",
    "updated_at": "2017-11-24T05:37:57.777Z"
  },
  {
    "id": 3,
    "callout_id": 1,
    "contact_id": 1,
    "callout_population_id": 1,
    "msisdn": "+252662345678",
    "call_flow_logic": null,
    "metadata": {},
    "created_at": "2017-11-24T05:38:41.562Z",
    "updated_at": "2017-11-24T05:38:41.562Z"
  },
  {
    "id": 4,
    "callout_id": 2,
    "contact_id": 1,
    "callout_population_id": 2,
    "msisdn": "+252662345678",
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "metadata": {},
    "created_at": "2017-11-24T05:47:50.534Z",
    "updated_at": "2017-11-24T05:47:50.534Z"
  },
  {
    "id": 5,
    "callout_id": 2,
    "contact_id": 2,
    "callout_population_id": 2,
    "msisdn": "+252662345679",
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "metadata": {},
    "created_at": "2017-11-24T05:47:50.545Z",
    "updated_at": "2017-11-24T05:47:50.545Z"
  }
]
```

Here we see a total of `4` callout participations across both of our callouts. This means that if we were to go ahead and execute the batch operation right now, phone calls would be created for all of these participations.

For this example we only wanted to create phone calls from the second callout, or the one which we started.

### Updating with filter parameters

Let's go ahead and specify some `callout_filter_params` so that our batch operation will only create phone calls for the callouts that are `running`. To do this let's go ahead and update the batch operation, this time specifying `callout_filter_params`. Note that we also need to specify the `remote_request_params` when updating the batch operation.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -XPATCH http://somleng-scfm:3000/api/batch_operations/3 --data-urlencode "parameters[remote_request_params][from]=1234" --data-urlencode "parameters[remote_request_params][url]=https://demo.twilio.com/docs/voice.xml" -d "parameters[remote_request_params][method]=GET" -d "parameters[callout_filter_params][status]=running"'

    < HTTP/1.1 204 No Content

### Fetching

Let's fetch the batch operation to make sure that our filter parameters were specified correctly:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/batch_operations/3 -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 3,
  "callout_id": null,
  "parameters": {
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "callout_filter_params": {
      "status": "running"
    }
  },
  "metadata": {},
  "status": "preview",
  "created_at": "2017-11-23T04:26:06.717Z",
  "updated_at": "2017-11-23T04:40:32.154Z"
}
```

### Previewing

Let's preview our batch operation again to see which callout participations will have phone calls created.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/batch_operations/3/preview/callout_participations -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 2

```json
[
  {
    "id": 4,
    "callout_id": 2,
    "contact_id": 1,
    "callout_population_id": 2,
    "msisdn": "+252662345678",
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "metadata": {},
    "created_at": "2017-11-24T05:47:50.534Z",
    "updated_at": "2017-11-24T05:47:50.534Z"
  },
  {
    "id": 5,
    "callout_id": 2,
    "contact_id": 2,
    "callout_population_id": 2,
    "msisdn": "+252662345679",
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "metadata": {},
    "created_at": "2017-11-24T05:47:50.545Z",
    "updated_at": "2017-11-24T05:47:50.545Z"
  }
]
```

Now we can see that the preview only shows the two callout participations from the second callout.

### Queuing

Now that we're happy with out batch operation let's go ahead and queue it.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/batch_operations/3/batch_operation_events -d event=queue -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 3,
  "callout_id": null,
  "parameters": {
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "callout_filter_params": {
      "status": "running"
    }
  },
  "metadata": {},
  "status": "queued",
  "created_at": "2017-11-23T04:26:06.717Z",
  "updated_at": "2017-11-23T04:45:54.390Z"
}
```

We can see theat the `status` is `queued`. Let's fetch it again to see if it's finished.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/batch_operations/3 -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 3,
  "callout_id": null,
  "parameters": {
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "callout_filter_params": {
      "status": "running"
    }
  },
  "metadata": {},
  "status": "finished",
  "created_at": "2017-11-23T04:26:06.717Z",
  "updated_at": "2017-11-23T04:45:54.483Z"
}
```

Now we can see that the `status` is `finished`, we can check to see the phone calls which have been created.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/batch_operations/3/phone_calls -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 2

```json
[
  {
    "id": 5,
    "callout_participation_id": 4,
    "contact_id": 1,
    "create_batch_operation_id": 3,
    "queue_batch_operation_id": null,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "created",
    "msisdn": "+252662345678",
    "remote_call_id": null,
    "remote_status": null,
    "remote_direction": null,
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {},
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "remotely_queued_at": null,
    "created_at": "2017-11-24T05:51:36.704Z",
    "updated_at": "2017-11-24T05:51:36.704Z"
  },
  {
    "id": 6,
    "callout_participation_id": 5,
    "contact_id": 2,
    "create_batch_operation_id": 3,
    "queue_batch_operation_id": null,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "created",
    "msisdn": "+252662345679",
    "remote_call_id": null,
    "remote_status": null,
    "remote_direction": null,
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {},
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "remotely_queued_at": null,
    "created_at": "2017-11-24T05:51:36.719Z",
    "updated_at": "2017-11-24T05:51:36.719Z"
  }
]
```

So we can see that two phone calls were created from this batch operation. One for Alice and one for Bob. Using the [Phone Calls API](#managing-phone-calls) we manage the phone calls created by this batch operation if we need to.

## Phone Call Batch Operations (Queue)

In the previous section we explained how to use a batch operation to create phone calls. The next logical step would be to create a batch operation to queue the calls on Twilio or Somleng. Let's go ahead and do this now:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/batch_operations -d type=BatchOperation::PhoneCallQueue -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 4,
  "callout_id": null,
  "parameters": {},
  "metadata": {},
  "status": "preview",
  "created_at": "2017-11-24T04:01:42.633Z",
  "updated_at": "2017-11-24T04:01:42.633Z"
}
```

### Previewing

We can see the `status` is `preview` so let's go ahead and preview the _phone calls_ which would be queued by this batch operation.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/batch_operations/4/preview/phone_calls -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 5

```json
[
  {
    "id": 1,
    "callout_participation_id": 3,
    "contact_id": 1,
    "create_batch_operation_id": null,
    "queue_batch_operation_id": null,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "remotely_queued",
    "msisdn": "+252662345678",
    "remote_call_id": "a887211a-b77f-4f3c-9b33-068ebbb5f54b",
    "remote_status": "queued",
    "remote_direction": "outbound-api",
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "345",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {
      "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
      "api_version": "2010-04-01",
      "date_created": "2017-11-24T05:40:57.000+00:00",
      "date_updated": "2017-11-24T05:40:57.000+00:00",
      "direction": "outbound-api",
      "from": "345",
      "from_formatted": "+34 5 ",
      "price": 0,
      "sid": "a887211a-b77f-4f3c-9b33-068ebbb5f54b",
      "status": "queued",
      "subresource_uris": {},
      "to": "+252662345678",
      "to_formatted": "+252 66 234 5678",
      "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/a887211a-b77f-4f3c-9b33-068ebbb5f54b"
    },
    "call_flow_logic": null,
    "remotely_queued_at": "2017-11-24T05:40:57.657Z",
    "created_at": "2017-11-24T05:39:20.522Z",
    "updated_at": "2017-11-24T05:40:57.657Z"
  },
  {
    "id": 3,
    "callout_participation_id": 3,
    "contact_id": 1,
    "create_batch_operation_id": null,
    "queue_batch_operation_id": null,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "canceled",
    "msisdn": "+252662345678",
    "remote_call_id": "082305b2-a0e4-4921-89bf-7bb544fd6910",
    "remote_status": "canceled",
    "remote_direction": "outbound-api",
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {
      "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
      "api_version": "2010-04-01",
      "date_created": "2017-11-24T05:43:19.000+00:00",
      "date_updated": "2017-11-24T05:43:19.000+00:00",
      "direction": "outbound-api",
      "from": "345",
      "from_formatted": "+34 5 ",
      "price": 0,
      "sid": "082305b2-a0e4-4921-89bf-7bb544fd6910",
      "status": "canceled",
      "subresource_uris": {},
      "to": "+252662345678",
      "to_formatted": "+252 66 234 5678",
      "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/082305b2-a0e4-4921-89bf-7bb544fd6910"
    },
    "remote_request_params": {
      "from": "345",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {
      "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
      "api_version": "2010-04-01",
      "date_created": "2017-11-24T05:43:19.000+00:00",
      "date_updated": "2017-11-24T05:43:19.000+00:00",
      "direction": "outbound-api",
      "from": "345",
      "from_formatted": "+34 5 ",
      "price": 0,
      "sid": "082305b2-a0e4-4921-89bf-7bb544fd6910",
      "status": "queued",
      "subresource_uris": {},
      "to": "+252662345678",
      "to_formatted": "+252 66 234 5678",
      "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/082305b2-a0e4-4921-89bf-7bb544fd6910"
    },
    "call_flow_logic": null,
    "remotely_queued_at": "2017-11-24T05:43:20.446Z",
    "created_at": "2017-11-24T05:41:38.394Z",
    "updated_at": "2017-11-24T05:44:06.099Z"
  },
  {
    "id": 4,
    "callout_participation_id": 3,
    "contact_id": 1,
    "create_batch_operation_id": null,
    "queue_batch_operation_id": null,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "remotely_queued",
    "msisdn": "+252662345678",
    "remote_call_id": "8ddfdac8-f200-4d07-be56-1444d9edfd7e",
    "remote_status": "queued",
    "remote_direction": "outbound-api",
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "345",
      "url": "http://18a2c6b3.ngrok.io/api/remote_phone_call_events"
    },
    "remote_queue_response": {
      "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
      "api_version": "2010-04-01",
      "date_created": "2017-11-24T05:46:42.000+00:00",
      "date_updated": "2017-11-24T05:46:42.000+00:00",
      "direction": "outbound-api",
      "from": "345",
      "from_formatted": "+34 5 ",
      "price": 0,
      "sid": "8ddfdac8-f200-4d07-be56-1444d9edfd7e",
      "status": "queued",
      "subresource_uris": {},
      "to": "+252662345678",
      "to_formatted": "+252 66 234 5678",
      "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/8ddfdac8-f200-4d07-be56-1444d9edfd7e"
    },
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "remotely_queued_at": "2017-11-24T05:46:43.246Z",
    "created_at": "2017-11-24T05:45:22.310Z",
    "updated_at": "2017-11-24T05:46:43.246Z"
  },
  {
    "id": 5,
    "callout_participation_id": 4,
    "contact_id": 1,
    "create_batch_operation_id": 3,
    "queue_batch_operation_id": null,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "created",
    "msisdn": "+252662345678",
    "remote_call_id": null,
    "remote_status": null,
    "remote_direction": null,
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {},
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "remotely_queued_at": null,
    "created_at": "2017-11-24T05:51:36.704Z",
    "updated_at": "2017-11-24T05:51:36.704Z"
  },
  {
    "id": 6,
    "callout_participation_id": 5,
    "contact_id": 2,
    "create_batch_operation_id": 3,
    "queue_batch_operation_id": null,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "created",
    "msisdn": "+252662345679",
    "remote_call_id": null,
    "remote_status": null,
    "remote_direction": null,
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {},
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "remotely_queued_at": null,
    "created_at": "2017-11-24T05:51:36.719Z",
    "updated_at": "2017-11-24T05:51:36.719Z"
  }
]
```

That's a lot of calls. In fact that's all the calls that we have created so far. For this example we only want to queue the calls from the `running` callout. Additionally we only want to queue calls that have the `status` `created` since `created` is the only state that can transition to `queued`.

### Updating with filter parameters

When queuing phone calls, we can filter on any of the attributes in the phone calls tables, in the callout participations table and in the callouts table. Let's update our batch operation with some filter parameters.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -XPATCH http://somleng-scfm:3000/api/batch_operations/4 -d "parameters[callout_filter_params][status]=running" -d "parameters[phone_call_filter_params][status]=created" -u $ACCESS_TOKEN:'

    < HTTP/1.1 204 No Content

### Fetching

To see the result let's fetch the batch operation:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/batch_operations/4 -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 4,
  "callout_id": null,
  "parameters": {
    "callout_filter_params": {
      "status": "running"
    },
    "phone_call_filter_params": {
      "status": "created"
    }
  },
  "metadata": {},
  "status": "preview",
  "created_at": "2017-11-24T05:57:01.035Z",
  "updated_at": "2017-11-24T06:42:54.029Z"
}
```

### Previewing

And preview it again:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/batch_operations/4/preview/phone_calls -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 2

```json
[
  {
    "id": 5,
    "callout_participation_id": 4,
    "contact_id": 1,
    "create_batch_operation_id": 3,
    "queue_batch_operation_id": null,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "created",
    "msisdn": "+252662345678",
    "remote_call_id": null,
    "remote_status": null,
    "remote_direction": null,
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {},
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "remotely_queued_at": null,
    "created_at": "2017-11-24T05:51:36.704Z",
    "updated_at": "2017-11-24T05:51:36.704Z"
  },
  {
    "id": 6,
    "callout_participation_id": 5,
    "contact_id": 2,
    "create_batch_operation_id": 3,
    "queue_batch_operation_id": null,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "created",
    "msisdn": "+252662345679",
    "remote_call_id": null,
    "remote_status": null,
    "remote_direction": null,
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {},
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "remotely_queued_at": null,
    "created_at": "2017-11-24T05:51:36.719Z",
    "updated_at": "2017-11-24T05:51:36.719Z"
  }
]
```

### Queuing

Now that we're happy with our batch operation let's go ahead and queue it.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/batch_operations/4/batch_operation_events -d event=queue -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 4,
  "callout_id": null,
  "parameters": {
    "callout_filter_params": {
      "status": "running"
    },
    "phone_call_filter_params": {
      "status": "created"
    }
  },
  "metadata": {},
  "status": "queued",
  "created_at": "2017-11-24T05:57:01.035Z",
  "updated_at": "2017-11-24T06:47:08.115Z"
}
```

We can see theat the status is queued. Let's fetch it again to see if it's finished.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/batch_operations/4 -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 4,
  "callout_id": null,
  "parameters": {
    "callout_filter_params": {
      "status": "running"
    },
    "phone_call_filter_params": {
      "status": "created"
    }
  },
  "metadata": {},
  "status": "finished",
  "created_at": "2017-11-24T05:57:01.035Z",
  "updated_at": "2017-11-24T06:47:08.115Z"
}
```

Now we can see that the `status` is `finished`, we can check to see the phone calls which have been queued.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/batch_operations/4/phone_calls -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 2

```json
[
  {
    "id": 5,
    "callout_participation_id": 4,
    "contact_id": 1,
    "create_batch_operation_id": 3,
    "queue_batch_operation_id": 4,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "remotely_queued",
    "msisdn": "+252662345678",
    "remote_call_id": "392be5ab-ad3e-4746-8076-de3995bda6a3",
    "remote_status": "queued",
    "remote_direction": "outbound-api",
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {
      "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
      "api_version": "2010-04-01",
      "date_created": "2017-11-24T06:47:08.000+00:00",
      "date_updated": "2017-11-24T06:47:08.000+00:00",
      "direction": "outbound-api",
      "from": "1234",
      "from_formatted": "+1 (234) ",
      "price": 0,
      "sid": "392be5ab-ad3e-4746-8076-de3995bda6a3",
      "status": "queued",
      "subresource_uris": {},
      "to": "+252662345678",
      "to_formatted": "+252 66 234 5678",
      "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/392be5ab-ad3e-4746-8076-de3995bda6a3"
    },
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "remotely_queued_at": "2017-11-24T06:47:09.246Z",
    "created_at": "2017-11-24T05:51:36.704Z",
    "updated_at": "2017-11-24T06:47:09.246Z"
  },
  {
    "id": 6,
    "callout_participation_id": 5,
    "contact_id": 2,
    "create_batch_operation_id": 3,
    "queue_batch_operation_id": 4,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "remotely_queued",
    "msisdn": "+252662345679",
    "remote_call_id": "b2d6480a-27ea-4c90-a39e-ea4adeae5209",
    "remote_status": "queued",
    "remote_direction": "outbound-api",
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {
      "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
      "api_version": "2010-04-01",
      "date_created": "2017-11-24T06:47:08.000+00:00",
      "date_updated": "2017-11-24T06:47:08.000+00:00",
      "direction": "outbound-api",
      "from": "1234",
      "from_formatted": "+1 (234) ",
      "price": 0,
      "sid": "b2d6480a-27ea-4c90-a39e-ea4adeae5209",
      "status": "queued",
      "subresource_uris": {},
      "to": "+252662345679",
      "to_formatted": "+252 66 234 5679",
      "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/b2d6480a-27ea-4c90-a39e-ea4adeae5209"
    },
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "remotely_queued_at": "2017-11-24T06:47:09.214Z",
    "created_at": "2017-11-24T05:51:36.719Z",
    "updated_at": "2017-11-24T06:47:09.214Z"
  }
]
```

Both of our phone calls now have the `status` `remotely_queued`.

## Phone Call Batch Operations (Queue Remote Status Fetch)

The last batch operation that we might want to do is to queue phone calls for a remote status fetch. To do this let's create a batch operation for fetching the remote status

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -XPOST http://somleng-scfm:3000/api/batch_operations -d type=BatchOperation::PhoneCallQueueRemoteFetch -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 5,
  "callout_id": null,
  "parameters": {},
  "metadata": {},
  "status": "preview",
  "created_at": "2017-11-24T07:30:29.220Z",
  "updated_at": "2017-11-24T07:30:29.220Z"
}
```

Once again, let's preview the batch operation to see which phone calls would be updated.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s -v http://somleng-scfm:3000/api/batch_operations/5/preview/phone_calls -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 5

```json
[
  {
    "id": 1,
    "callout_participation_id": 3,
    "contact_id": 1,
    "create_batch_operation_id": null,
    "queue_batch_operation_id": null,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "remotely_queued",
    "msisdn": "+252662345678",
    "remote_call_id": "a887211a-b77f-4f3c-9b33-068ebbb5f54b",
    "remote_status": "queued",
    "remote_direction": "outbound-api",
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "345",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {
      "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
      "api_version": "2010-04-01",
      "date_created": "2017-11-24T05:40:57.000+00:00",
      "date_updated": "2017-11-24T05:40:57.000+00:00",
      "direction": "outbound-api",
      "from": "345",
      "from_formatted": "+34 5 ",
      "price": 0,
      "sid": "a887211a-b77f-4f3c-9b33-068ebbb5f54b",
      "status": "queued",
      "subresource_uris": {},
      "to": "+252662345678",
      "to_formatted": "+252 66 234 5678",
      "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/a887211a-b77f-4f3c-9b33-068ebbb5f54b"
    },
    "call_flow_logic": null,
    "remotely_queued_at": "2017-11-24T05:40:57.657Z",
    "created_at": "2017-11-24T05:39:20.522Z",
    "updated_at": "2017-11-24T05:40:57.657Z"
  },
  {
    "id": 3,
    "callout_participation_id": 3,
    "contact_id": 1,
    "create_batch_operation_id": null,
    "queue_batch_operation_id": null,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "canceled",
    "msisdn": "+252662345678",
    "remote_call_id": "082305b2-a0e4-4921-89bf-7bb544fd6910",
    "remote_status": "canceled",
    "remote_direction": "outbound-api",
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {
      "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
      "api_version": "2010-04-01",
      "date_created": "2017-11-24T05:43:19.000+00:00",
      "date_updated": "2017-11-24T05:43:19.000+00:00",
      "direction": "outbound-api",
      "from": "345",
      "from_formatted": "+34 5 ",
      "price": 0,
      "sid": "082305b2-a0e4-4921-89bf-7bb544fd6910",
      "status": "canceled",
      "subresource_uris": {},
      "to": "+252662345678",
      "to_formatted": "+252 66 234 5678",
      "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/082305b2-a0e4-4921-89bf-7bb544fd6910"
    },
    "remote_request_params": {
      "from": "345",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {
      "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
      "api_version": "2010-04-01",
      "date_created": "2017-11-24T05:43:19.000+00:00",
      "date_updated": "2017-11-24T05:43:19.000+00:00",
      "direction": "outbound-api",
      "from": "345",
      "from_formatted": "+34 5 ",
      "price": 0,
      "sid": "082305b2-a0e4-4921-89bf-7bb544fd6910",
      "status": "queued",
      "subresource_uris": {},
      "to": "+252662345678",
      "to_formatted": "+252 66 234 5678",
      "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/082305b2-a0e4-4921-89bf-7bb544fd6910"
    },
    "call_flow_logic": null,
    "remotely_queued_at": "2017-11-24T05:43:20.446Z",
    "created_at": "2017-11-24T05:41:38.394Z",
    "updated_at": "2017-11-24T05:44:06.099Z"
  },
  {
    "id": 4,
    "callout_participation_id": 3,
    "contact_id": 1,
    "create_batch_operation_id": null,
    "queue_batch_operation_id": null,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "remotely_queued",
    "msisdn": "+252662345678",
    "remote_call_id": "8ddfdac8-f200-4d07-be56-1444d9edfd7e",
    "remote_status": "queued",
    "remote_direction": "outbound-api",
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "345",
      "url": "http://18a2c6b3.ngrok.io/api/remote_phone_call_events"
    },
    "remote_queue_response": {
      "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
      "api_version": "2010-04-01",
      "date_created": "2017-11-24T05:46:42.000+00:00",
      "date_updated": "2017-11-24T05:46:42.000+00:00",
      "direction": "outbound-api",
      "from": "345",
      "from_formatted": "+34 5 ",
      "price": 0,
      "sid": "8ddfdac8-f200-4d07-be56-1444d9edfd7e",
      "status": "queued",
      "subresource_uris": {},
      "to": "+252662345678",
      "to_formatted": "+252 66 234 5678",
      "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/8ddfdac8-f200-4d07-be56-1444d9edfd7e"
    },
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "remotely_queued_at": "2017-11-24T05:46:43.246Z",
    "created_at": "2017-11-24T05:45:22.310Z",
    "updated_at": "2017-11-24T05:46:43.246Z"
  },
  {
    "id": 5,
    "callout_participation_id": 4,
    "contact_id": 1,
    "create_batch_operation_id": 3,
    "queue_batch_operation_id": 4,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "remotely_queued",
    "msisdn": "+252662345678",
    "remote_call_id": "392be5ab-ad3e-4746-8076-de3995bda6a3",
    "remote_status": "queued",
    "remote_direction": "outbound-api",
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {
      "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
      "api_version": "2010-04-01",
      "date_created": "2017-11-24T06:47:08.000+00:00",
      "date_updated": "2017-11-24T06:47:08.000+00:00",
      "direction": "outbound-api",
      "from": "1234",
      "from_formatted": "+1 (234) ",
      "price": 0,
      "sid": "392be5ab-ad3e-4746-8076-de3995bda6a3",
      "status": "queued",
      "subresource_uris": {},
      "to": "+252662345678",
      "to_formatted": "+252 66 234 5678",
      "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/392be5ab-ad3e-4746-8076-de3995bda6a3"
    },
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "remotely_queued_at": "2017-11-24T06:47:09.246Z",
    "created_at": "2017-11-24T05:51:36.704Z",
    "updated_at": "2017-11-24T06:47:09.246Z"
  },
  {
    "id": 6,
    "callout_participation_id": 5,
    "contact_id": 2,
    "create_batch_operation_id": 3,
    "queue_batch_operation_id": 4,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "remotely_queued",
    "msisdn": "+252662345679",
    "remote_call_id": "b2d6480a-27ea-4c90-a39e-ea4adeae5209",
    "remote_status": "queued",
    "remote_direction": "outbound-api",
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {
      "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
      "api_version": "2010-04-01",
      "date_created": "2017-11-24T06:47:08.000+00:00",
      "date_updated": "2017-11-24T06:47:08.000+00:00",
      "direction": "outbound-api",
      "from": "1234",
      "from_formatted": "+1 (234) ",
      "price": 0,
      "sid": "b2d6480a-27ea-4c90-a39e-ea4adeae5209",
      "status": "queued",
      "subresource_uris": {},
      "to": "+252662345679",
      "to_formatted": "+252 66 234 5679",
      "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/b2d6480a-27ea-4c90-a39e-ea4adeae5209"
    },
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "remotely_queued_at": "2017-11-24T06:47:09.214Z",
    "created_at": "2017-11-24T05:51:36.719Z",
    "updated_at": "2017-11-24T06:47:09.214Z"
  }
]
```

Once again this displays all the phone calls because we haven't yet specified any filter parameters.

### Updating with filter parameters

When updating the remote status, we're only interested in the calls that have the `status` `remotely_queued` OR `in_progress`. Let's update our batch operation to filter on those statuses. For this example we'll also filter on the callout which is `running`.

Note that in the command below we specify the statuses as a comma separated list:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -XPATCH http://somleng-scfm:3000/api/batch_operations/5 -d "parameters[callout_filter_params][status]=running" -d "parameters[phone_call_filter_params][status]=remotely_queued,in_progress" -u $ACCESS_TOKEN:'

    < HTTP/1.1 204 No Content

### Fetching

To see the result let's fetch the batch operation:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/batch_operations/5 -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 5,
  "callout_id": null,
  "parameters": {
    "callout_filter_params": {
      "status": "running"
    },
    "phone_call_filter_params": {
      "status": "remotely_queued,in_progress"
    }
  },
  "metadata": {},
  "status": "preview",
  "created_at": "2017-11-24T07:30:29.220Z",
  "updated_at": "2017-11-24T08:52:52.602Z"
}
```

### Previewing

And preview it again:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/batch_operations/5/preview/phone_calls -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 2

```json
[
  {
    "id": 5,
    "callout_participation_id": 4,
    "contact_id": 1,
    "create_batch_operation_id": 3,
    "queue_batch_operation_id": 4,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "remotely_queued",
    "msisdn": "+252662345678",
    "remote_call_id": "392be5ab-ad3e-4746-8076-de3995bda6a3",
    "remote_status": "queued",
    "remote_direction": "outbound-api",
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {
      "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
      "api_version": "2010-04-01",
      "date_created": "2017-11-24T06:47:08.000+00:00",
      "date_updated": "2017-11-24T06:47:08.000+00:00",
      "direction": "outbound-api",
      "from": "1234",
      "from_formatted": "+1 (234) ",
      "price": 0,
      "sid": "392be5ab-ad3e-4746-8076-de3995bda6a3",
      "status": "queued",
      "subresource_uris": {},
      "to": "+252662345678",
      "to_formatted": "+252 66 234 5678",
      "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/392be5ab-ad3e-4746-8076-de3995bda6a3"
    },
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "remotely_queued_at": "2017-11-24T06:47:09.246Z",
    "created_at": "2017-11-24T05:51:36.704Z",
    "updated_at": "2017-11-24T06:47:09.246Z"
  },
  {
    "id": 6,
    "callout_participation_id": 5,
    "contact_id": 2,
    "create_batch_operation_id": 3,
    "queue_batch_operation_id": 4,
    "queue_remote_fetch_batch_operation_id": null,
    "status": "remotely_queued",
    "msisdn": "+252662345679",
    "remote_call_id": "b2d6480a-27ea-4c90-a39e-ea4adeae5209",
    "remote_status": "queued",
    "remote_direction": "outbound-api",
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {},
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {
      "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
      "api_version": "2010-04-01",
      "date_created": "2017-11-24T06:47:08.000+00:00",
      "date_updated": "2017-11-24T06:47:08.000+00:00",
      "direction": "outbound-api",
      "from": "1234",
      "from_formatted": "+1 (234) ",
      "price": 0,
      "sid": "b2d6480a-27ea-4c90-a39e-ea4adeae5209",
      "status": "queued",
      "subresource_uris": {},
      "to": "+252662345679",
      "to_formatted": "+252 66 234 5679",
      "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/b2d6480a-27ea-4c90-a39e-ea4adeae5209"
    },
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "remotely_queued_at": "2017-11-24T06:47:09.214Z",
    "created_at": "2017-11-24T05:51:36.719Z",
    "updated_at": "2017-11-24T06:47:09.214Z"
  }
]
```

We can see that this filter now returns only our phone calls which have the `status` `remotely_queued` and that are from our running callout.

### Limiting

We can further limit the number of calls which will be updated by specifying a limit. Let's do this by updating our batch operation parameters again and setting the `limit` to `1`. Note that we also need to specify our filter parameters otherwise they'll be overridden.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -XPATCH http://somleng-scfm:3000/api/batch_operations/5 -d "parameters[callout_filter_params][status]=running" -d "parameters[phone_call_filter_params][status]=remotely_queued,in_progress" -d "parameters[limit]=1" -u $ACCESS_TOKEN:'

    < HTTP/1.1 204 No Content

Let's fetch it again to make sure it was updated

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/batch_operations/5 -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 5,
  "callout_id": null,
  "parameters": {
    "callout_filter_params": {
      "status": "running"
    },
    "phone_call_filter_params": {
      "status": "remotely_queued,in_progress"
    },
    "limit": "1"
  },
  "metadata": {},
  "status": "preview",
  "created_at": "2017-11-24T07:30:29.220Z",
  "updated_at": "2017-11-24T08:59:49.310Z"
}
```

We can see that the `limit` parameter has been set correctly.

### Queueing

Let's go ahead and queue our batch operation.

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/batch_operations/5/batch_operation_events -d event=queue -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 5,
  "callout_id": null,
  "parameters": {
    "callout_filter_params": {
      "status": "running"
    },
    "phone_call_filter_params": {
      "status": "remotely_queued,in_progress"
    },
    "limit": "1"
  },
  "metadata": {},
  "status": "queued",
  "created_at": "2017-11-24T07:30:29.220Z",
  "updated_at": "2017-11-24T08:59:49.310Z"
}
```

And fetch it to check if it's finished:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -s http://somleng-scfm:3000/api/batch_operations/5 -u $ACCESS_TOKEN: | jq'

```json
{
  "id": 5,
  "callout_id": null,
  "parameters": {
    "callout_filter_params": {
      "status": "running"
    },
    "phone_call_filter_params": {
      "status": "remotely_queued,in_progress"
    },
    "limit": "1"
  },
  "metadata": {},
  "status": "finished",
  "created_at": "2017-11-24T07:30:29.220Z",
  "updated_at": "2017-11-24T08:59:49.310Z"
}
```

Finally check the phone calls were updated:

    $ docker-compose run --rm -e ACCESS_TOKEN=$ACCESS_TOKEN curl /bin/sh -c 'curl -v -s http://somleng-scfm:3000/api/batch_operations/5/phone_calls -u $ACCESS_TOKEN: | jq'

    < Per-Page: 25
    < Total: 1

```json
[
  {
    "id": 5,
    "callout_participation_id": 4,
    "contact_id": 1,
    "create_batch_operation_id": 3,
    "queue_batch_operation_id": 4,
    "queue_remote_fetch_batch_operation_id": 5,
    "status": "canceled",
    "msisdn": "+252662345678",
    "remote_call_id": "392be5ab-ad3e-4746-8076-de3995bda6a3",
    "remote_status": "canceled",
    "remote_direction": "outbound-api",
    "remote_error_message": null,
    "metadata": {},
    "remote_response": {
      "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
      "api_version": "2010-04-01",
      "date_created": "2017-11-24T06:47:08.000+00:00",
      "date_updated": "2017-11-24T06:47:09.000+00:00",
      "direction": "outbound-api",
      "from": "1234",
      "from_formatted": "+1 (234) ",
      "price": 0,
      "sid": "392be5ab-ad3e-4746-8076-de3995bda6a3",
      "status": "canceled",
      "subresource_uris": {},
      "to": "+252662345678",
      "to_formatted": "+252 66 234 5678",
      "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/392be5ab-ad3e-4746-8076-de3995bda6a3"
    },
    "remote_request_params": {
      "from": "1234",
      "url": "https://demo.twilio.com/docs/voice.xml",
      "method": "GET"
    },
    "remote_queue_response": {
      "account_sid": "0213d485-12cb-4d0d-9cb1-966546240a57",
      "api_version": "2010-04-01",
      "date_created": "2017-11-24T06:47:08.000+00:00",
      "date_updated": "2017-11-24T06:47:08.000+00:00",
      "direction": "outbound-api",
      "from": "1234",
      "from_formatted": "+1 (234) ",
      "price": 0,
      "sid": "392be5ab-ad3e-4746-8076-de3995bda6a3",
      "status": "queued",
      "subresource_uris": {},
      "to": "+252662345678",
      "to_formatted": "+252 66 234 5678",
      "uri": "/api/2010-04-01/Accounts/0213d485-12cb-4d0d-9cb1-966546240a57/Calls/392be5ab-ad3e-4746-8076-de3995bda6a3"
    },
    "call_flow_logic": "CallFlowLogic::AvfCapom::CapomShort",
    "remotely_queued_at": "2017-11-24T06:47:09.246Z",
    "created_at": "2017-11-24T05:51:36.704Z",
    "updated_at": "2017-11-24T09:12:07.749Z"
  }
]
```

As we can see the phone call has been updated with the remote status but only 1 phone call was returned. This is because we specified a limit of `1`.
