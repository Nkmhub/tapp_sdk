import Foundation

typealias InitializeTappCompletion = (_ result: Result<Void, Error>) -> Void
typealias NetworkServiceCompletion = (_ result: Result<Data, Error>) -> Void
typealias DataTaskCompletion = (Data?, URLResponse?, Error?) -> Void
typealias SecretsCompletion = (_ result: Result<SecretsResponse, Error>) -> Void
typealias LinkDataCompletion = (_ result: Result<TappDeferredLinkDataDTO, Error>) -> Void
